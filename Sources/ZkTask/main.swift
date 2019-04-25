import Foundation
import CommandLineKit
import Rainbow
import TaskKit

let cli = CommandLineKit.CommandLine()
cli.formatOutput = { str, type in
    var string: String
    switch(type) {
    case .error:
        string = str.red.bold
    case .optionFlag:
        string = str.green
    case .optionHelp:
        string = str.lightMagenta
    default:
        string = str
    }
    return cli.defaultFormat(s: string, type: type)
}

let path = StringOption(shortFlag: "p", longFlag: "Path", required: true,
                        helpMessage: "config 文件地址")
cli.addOptions(path)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

let filePath = path.value!
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
