#include "vmlinux.h"
#include <bpf/bpf_helpers.h>

#define FNAME_LEN 32
struct exec_data_t {
	u32 pid;
	u8 fname[FNAME_LEN];
	u8 comm[FNAME_LEN];
};

// For Rust libbpf-rs only
struct exec_data_t _edt = {0};

struct {
	__uint(type, BPF_MAP_TYPE_PERF_EVENT_ARRAY);
	__uint(key_size, sizeof(u32));
	__uint(value_size, sizeof(u32));
} events SEC(".maps");

struct execve_entry_args_t {
	u64 _unused;
	u64 _unused2;

	const char* filename;
	const char* const* argv;
	const char* const* envp;
};

#define LAST_32_BITS(x) x & 0xFFFFFFFF
#define FIRST_32_BITS(x) x >> 32

SEC("tracepoint/syscalls/sys_enter_execve")
int enter_execve(struct execve_entry_args_t *args)
{
	struct exec_data_t exec_data = {};
	u64 pid_tgid;

	pid_tgid = bpf_get_current_pid_tgid();
	exec_data.pid = LAST_32_BITS(pid_tgid);

	bpf_probe_read_user_str(exec_data.fname,
		sizeof(exec_data.fname), args->filename);

	bpf_get_current_comm(exec_data.comm, sizeof(exec_data.comm));

	bpf_perf_event_output(args, &events,
		BPF_F_CURRENT_CPU, &exec_data, sizeof(exec_data));

	bpf_printk("hello, world\n");

	return 0;
}

char LICENSE[] SEC("license") = "GPL";