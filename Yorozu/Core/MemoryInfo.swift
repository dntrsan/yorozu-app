import Foundation
import os

enum MemoryInfo {
    /// このアプリが実際に使っているメモリ(iOS が上限判定に使う値)
    static var footprint: UInt64 {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        return kr == KERN_SUCCESS ? info.phys_footprint : 0
    }

    /// あとどれだけ使えるか(これが0に近づくと iOS に落とされる)
    static var available: UInt64 { UInt64(os_proc_available_memory()) }
}
