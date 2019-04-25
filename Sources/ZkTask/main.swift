import TaskKit
import Foundation

let filePath = detectDirectory() + "config.json"
let fileUrl = URL(fileURLWithPath: filePath)
let fileData = try! Data(contentsOf: fileUrl)
let manager = TaskManager.shared
let decoder = JSONDecoder()
do {
    let config = try decoder.decode(Config.self, from: fileData)
    config.serializeTask().forEach { manager.addTask($0) }
    manager.fireAll()
} catch {
    print(error)
}

func exitGracefully(pid: CInt) {
    print("stopping...")
    manager.cancelAll()
    exit(EX_USAGE)
}

signal(SIGINT, exitGracefully)
signal(SIGTERM, exitGracefully)
print("推流中...")

let lock = ConditionLock(value: 0)
lock.lock(whenValue: 1)
