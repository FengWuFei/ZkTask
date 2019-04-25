import Foundation
import TaskKit

class AnyFFmpegTask: Task {
    var taskArguments: [String]
    var identifier: String
    var option: TaskParsedOptionsInfo
    var onError: ((Error) -> Void)?
    var process: Process?
    
    init(taskArguments: [String], identifier: String, option: TaskParsedOptionsInfo) {
        self.taskArguments = taskArguments
        self.identifier = identifier
        self.option = option
    }
}

extension TaskType: Codable {}
extension QualityOfService: Codable {}

struct TaskTemplate: Codable {
    var identifier: String
    var arguments: [String]
}

struct TaskInfo: Codable {
    var type: String
    var inputUrl: [String]
    var outputUrl: String
}

struct Config: Codable {
    var taskType: TaskType?
    var executablePath: String?
    var directoryPath: String?
    var quality: QualityOfService?
    var template: [TaskTemplate]
    var tasks: [TaskInfo]
    
    func serializeTask() -> [AnyFFmpegTask] {
        var taskList = [AnyFFmpegTask]()
        tasks.forEach { taskInfo in
            let argumentsInfo = template.first { $0.identifier == taskInfo.type }?.arguments
            guard let optionArguments = argumentsInfo else { return }
            let inputStr = taskInfo.inputUrl
            let outputStr = taskInfo.outputUrl
            
            var inputUrls = [String]()
            inputStr.forEach { v in
                if v.contains("-") {
                    let strs = v.split(separator: "-")
                    assertArrayCount(array: strs, count: 2)
                    var topList = strs[0].split(separator: ".")
                    var bottomList = strs[1].split(separator: ":")
                    assertArrayCount(array: topList, count: 4)
                    assertArrayCount(array: bottomList, count: 2)
                    
                    let startIndex = assertNotNil(Int(String(topList[3])), message: "startIndex")
                    let endIndex = assertNotNil(Int(String(bottomList[0])), message: "endIndex")
                    (startIndex...endIndex).forEach { index in
                        topList[3] = Substring.SubSequence(String(index))
                        let res = topList.joined(separator: ".") + ":" + String(bottomList[1])
                        inputUrls.append(res)
                    }
                } else {
                    inputUrls.append(v)
                }
            }
            
            var ffmpegOption: TaskOptionsInfo = []
            if let ffmpegTaskType = taskType {
                ffmpegOption.append(.taskType(ffmpegTaskType))
            }
            if let ffmpegExecutablePath = executablePath {
                ffmpegOption.append(.executablePath(ffmpegExecutablePath))
            }
            if let ffmpegDirectoryPath = directoryPath {
                ffmpegOption.append(.directoryPath(ffmpegDirectoryPath))
            }
            if let ffmpgeQuality = quality {
                ffmpegOption.append(.quality(ffmpgeQuality))
            }
            
            var index = 1
            inputUrls.forEach { inputUrl in
                var outputUrl = ""
                if inputUrls.count > 1 {
                    outputUrl = outputStr + "\(index)"
                    index += 1
                } else {
                    outputUrl = outputStr
                }
                let ffmpegArguments = ["-i"] + [inputUrl] + optionArguments + [outputUrl]
                let newTask = AnyFFmpegTask(taskArguments: ffmpegArguments, identifier: outputUrl, option: TaskParsedOptionsInfo(ffmpegOption))
                taskList.append(newTask)
            }
        }
        return taskList
    }
    
    private func assertArrayCount<T>(array: [T], count: Int) {
        if array.count != count {
            fatalError("wraong: \(array)")
        }
    }
    
    private func assertNotNil<T>(_ value: Optional<T>, message: String) -> T {
        guard let res = value else {
            fatalError("wraong: \(message) is nil")
        }
        return res
    }
}

