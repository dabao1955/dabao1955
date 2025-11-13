gcov 和 perf 优化实战
===
## 起源
最近几个月除了正常的刷版号，折腾 Android Kernel 以外我还学了一点点 C 语言和比较基本的编译原理。为此我专门写了一个 BrainFuck Compiler(简称 bfc，下同)。主要是 BrainFuck(简称 bf，下同) 只有8个字符，学习起来还是比较简单的，就是有点费手。不过当我在测试 awib.bf 的时候发现在生成 C 代码时总会比其他的 bf 慢上零点几秒。我一开始考虑到可能是 awib 比较大处理比较慢的问题。
直到我在折腾如何优化内核的时候偶然了解到 pgo ，里面就提到了 gcov 这个工具。于是就开始了今天的折腾。

## 安装
由于 gcc 自带 gcov，且不需要 lcov 这种可视化工具，所以只需要安装 perf 即可，而 perf 命令是来自 linux-tools:
```bash
$ sudo apt install linux-tools*
```
## 使用
在编译的时候语言通过参数启用插桩:
```bash
gcc -fprofile-arcs -ftest-coverage bfc.c -O0 -g3 -o bfc
```
然后会生成 bfc.gcno 文件。

这个时候再运行一下 perf:
```bash
$ perf record ./bfc -f tests/awib.b awub.c
WARNING: Kernel address maps (/proc/{kallsyms,modules}) are restricted,
check /proc/sys/kernel/kptr_restrict and /proc/sys/kernel/perf_event_paranoid.

Samples in kernel functions may not be resolved if a suitable vmlinux
file is not found in the buildid cache or in the vmlinux path.

Samples in kernel modules won't be resolved at all.

If some relocation was applied (e.g. kexec) symbols may be misresolved
even with a suitable vmlinux or kallsyms file.

Couldn't record kernel reference relocation symbol
Symbol resolution may be skewed if relocation was used (e.g. kexec).
Check /proc/kallsyms permission or run as root.
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.012 MB perf.data (287 samples) ]
```
此时会生成 bfc.gcda 和 perf.data
这个时候再运行一下:
```bash
$ perf report
```
我们得到了更详细的数据:
```
  71.77%  bfc      bfc                    [.] generate_c_code
   2.46%  bfc      bfc                    [.] optimize_arithmetic
   2.38%  bfc      libc.so.6              [.] _IO_file_xsputn
   2.05%  bfc      bfc                    [.] parse_bf_code
   1.28%  bfc      libc.so.6              [.] _IO_fwrite
   1.11%  bfc      [unknown]              [k] 0xffffffe675e9ffb8
   1.05%  bfc      bfc                    [.] is_copy_loop
   1.00%  bfc      bfc                    [.] add_instruction
   0.94%  bfc      [unknown]              [k] 0xffffffdb211cbe40
   0.87%  bfc      bfc                    [.] eliminate_dead_code
   0.69%  bfc      bfc                    [.] is_clear_loop
   0.66%  bfc      [unknown]              [k] 0xffffffdb211cbdf0
   0.56%  bfc      bfc                    [.] build_bracket_mapping
   0.54%  bfc      bfc                    [.] propagate_constants
   0.48%  bfc      [unknown]              [k] 0xffffffdb203e6190
   0.48%  bfc      libc.so.6              [.] 0x00000000000a3118
```
这个时候我们就知道是 generate_c_code 这个函数使用了71.77% 的 cpu。

接下来使用:
```bash
$ gcov bfc.c
File 'bfc.c'
Lines executed:83.27% of 550
Creating 'bfc.c.gcov'

Lines executed:83.27% of 550
```
生成 bfc.c.gcov 查看 generate_c_code 函数中有哪些行执行了多次从而占用了大量的 cpu:
```C
        -:  670:        // 添加适当的缩进
   223005:  671:        for (int d = 0; d < loop_depth; d++) {
   208225:  672:            fprintf(output, "    ");
        -:  673:        }
```
这个是添加缩进，但是这个不是大头，先暂且略过

然后发现了:
```C
     1202:  775:                if (loop_depth > 0) {
        -:  776:                    // 查找对应的 LOOP_START 位置
     1202:  777:                    int end_pc = i;
     1202:  778:                    int start_pc = -1;
 11045175:  779:                    for (int j = 0; j < instr_count; j++) {
 11045175:  780:                        if (instructions[j].type == BF_LOOP_START &&
   727682:  781:                            !instructions[j].eliminated &&
   727682:  782:                            bracket_map[j] == end_pc) {
     1202:  783:                            start_pc = j;
     1202:  784:                                break;
        -:  785:                        }
        -:  786:                    }
```
不难看出这个循环执行了 1100w 次是导致 cpu 占用过大的罪魁祸首。

## 优化

在 Brainfuck 解释器中，当执行到 `]`（循环结束）时，需要快速找到它对应的 `[`（循环开始）的位置，以便决定是否跳回循环开头。

这个 for 循环在每次遇到`]`时就遍历整个 bf 代码，而 awib 本身就是一个用 bf 写的 bf 解释器，代码量非常大。所以就出现了一个 for 循环执行了最坏的情况，即 O(n) 次。

而且我当时并不知道我事先在处理语法错误的位置的时候已经预处理了(这个还是问 llm 才得到的，我一开始并不知道，我笨，我紫菜):

```C
static void build_bracket_mapping() {
    if (bracket_map) free(bracket_map);
    bracket_map = calloc(instr_count, sizeof(int));

    int *stack = malloc(instr_count * sizeof(int));
    int top = -1;

    for (int i = 0; i < instr_count; i++) {
        if (instructions[i].type == BF_LOOP_START) {
            stack[++top] = i;
        } else if (instructions[i].type == BF_LOOP_END) {
            if (top < 0) {
                fprintf(stderr, "语法错误: 多余的 ] 在位置 %d\n", i);
                exit(1);
            }
            int start = stack[top--];
            bracket_map[start] = i;
            bracket_map[i] = start;
        }
    }

    if (top >= 0) {
        fprintf(stderr, "语法错误: 缺少 ]\n");
        exit(1);
    }

    free(stack);
}
```

最后的解决办法就是扬掉遍历，使用预处理:
```diff
- int start_pc = -1;
+ int start_pc = bracket_map[end_pc];

```
根据 perf report 得知优化明显:
```perf
  18.56%  bfc      libc.so.6              [.] _IO_fwrite
  10.66%  bfc      bfc                    [.] generate_c_code
   5.32%  bfc      bfc                    [.] parse_bf_code
   3.88%  bfc      libc.so.6              [.] _IO_file_xsputn
   3.61%  bfc      [unknown]              [k] 0xffffffdb2039245c
   3.40%  bfc      bfc                    [.] is_copy_loop
   3.21%  bfc      bfc                    [.] propagate_constants
   3.18%  bfc      bfc                    [.] optimize_arithmetic
   2.60%  bfc      libc.so.6              [.] 0x00000000000a3114
   2.42%  bfc      libc.so.6              [.] 0x00000000000a311c
   2.12%  bfc      [unknown]              [k] 0xffffffe675e9ffb8
```
查看循环次数
```C
     1202:  775:                if (loop_depth > 0) {
        -:  776:                    // 查找对应的 LOOP_START 位置
     1202:  777:                    int end_pc = i;
     1202:  778:                    int start_pc = bracket_map[end_pc];
        -:  779:
        -:  780:                    // 只有当循环体没有退出机制时，才插入 mem[ptr]--
     1202:  781:                    if (start_pc != -1 && !loop_exits_eventually(start_pc, end_pc)) {
     4575:  782:                        for (int d = 0; d < loop_depth; d++) {
     4230:  783:                            fprintf(output, "    ");
        -:  784:                        }
      345:  785:                        fprintf(output, "mem[ptr]--;\n");
```
可以看到调用次数仅为 1202 次，符合预期。

