//
//  PluginManager.swift
//  MultiCalendarApp
//
//  插件管理器 - 负责插件的加载、卸载和管理
//

import Foundation
import Combine

/// 插件管理器
class PluginManager: ObservableObject {
    
    // MARK: - 单例
    
    static let shared = PluginManager()
    
    // MARK: - Published Properties
    
    @Published var loadedPlugins: [String: CalendarPlugin] = [:]
    @Published var availablePlugins: [CalendarPluginMetadata] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private let fileManager = FileManager.default
    private let pluginDirectory: URL
    private let bundledPluginsDirectory: URL
    
    // MARK: - Initialization
    
    private init() {
        // 插件目录
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.pluginDirectory = appSupport.appendingPathComponent("CalendarPlugins")
        self.bundledPluginsDirectory = Bundle.main.bundleURL.appendingPathComponent("Plugins")
        
        // 创建插件目录
        try? fileManager.createDirectory(at: pluginDirectory, withIntermediateDirectories: true)
        
        // 加载内置插件
        loadBundledPlugins()
    }
    
    // MARK: - 插件加载
    
    /// 加载内置插件
    private func loadBundledPlugins() {
        // 查找内置插件
        if let pluginURLs = try? fileManager.contentsOfDirectory(at: bundledPluginsDirectory, includingPropertiesForKeys: nil) {
            for pluginURL in pluginURLs {
                if pluginURL.pathExtension == "bundle" {
                    loadPlugin(from: pluginURL)
                }
            }
        }
        
        // 加载农历插件（内置编译）
        let lunarPlugin = LunarCalendarPlugin()
        registerPlugin(lunarPlugin)
    }
    
    /// 从 Bundle 加载插件
    private func loadPlugin(from url: URL) {
        guard let bundle = Bundle(url: url) else {
            print("Failed to load bundle: \(url)")
            return
        }
        
        // 读取插件元数据
        guard let metadataPath = bundle.path(forResource: "CalendarPlugin", ofType: "json"),
              let metadataData = fileManager.contents(atPath: metadataPath),
              let metadata = try? JSONDecoder().decode(CalendarPluginMetadata.self, from: metadataData) else {
            print("Failed to load plugin metadata: \(url)")
            return
        }
        
        // TODO: 动态加载插件代码
        // 目前仅支持资源型插件（数据文件）
        
        print("Loaded plugin: \(metadata.name) v\(metadata.version)")
    }
    
    /// 注册插件
    func registerPlugin(_ plugin: CalendarPlugin) {
        loadedPlugins[plugin.identifier] = plugin
        print("Registered plugin: \(plugin.name)")
    }
    
    /// 卸载插件
    func unregisterPlugin(identifier: String) {
        loadedPlugins.removeValue(forKey: identifier)
        print("Unregistered plugin: \(identifier)")
    }
    
    // MARK: - 远程插件管理
    
    /// 获取可用的远程插件列表
    func fetchAvailablePlugins() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: 从服务器获取插件列表
        // let url = URL(string: "https://api.example.com/calendar/plugins")!
        // let (data, _) = try await URLSession.shared.data(from: url)
        // availablePlugins = try JSONDecoder().decode([CalendarPluginMetadata].self, from: data)
    }
    
    /// 下载并安装插件
    func downloadAndInstallPlugin(metadata: CalendarPluginMetadata) async throws {
        guard let downloadURL = metadata.downloadURL else {
            throw PluginError.invalidDownloadURL
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // 下载插件包
        let (localURL, _) = try await URLSession.shared.download(from: URL(string: downloadURL)!)
        
        // 移动到插件目录
        let destinationURL = pluginDirectory.appendingPathComponent("\(metadata.identifier).bundle")
        try? fileManager.removeItem(at: destinationURL)
        try fileManager.moveItem(at: localURL, to: destinationURL)
        
        // 加载插件
        loadPlugin(from: destinationURL)
    }
    
    /// 删除插件
    func deletePlugin(identifier: String) throws {
        let pluginURL = pluginDirectory.appendingPathComponent("\(identifier).bundle")
        try fileManager.removeItem(at: pluginURL)
        unregisterPlugin(identifier: identifier)
    }
    
    // MARK: - 插件查询
    
    /// 获取指定类型的插件
    func getPlugin(for calendarType: CalendarType) -> CalendarPlugin? {
        return loadedPlugins.values.first { $0.calendarType == calendarType }
    }
    
    /// 获取所有已加载的历法类型
    func getLoadedCalendarTypes() -> [CalendarType] {
        return loadedPlugins.values.map { $0.calendarType }
    }
    
    /// 检查插件是否已安装
    func isPluginInstalled(identifier: String) -> Bool {
        return loadedPlugins[identifier] != nil
    }
    
    /// 检查插件是否需要更新
    func checkForUpdates() async throws -> [String: String] {
        // TODO: 检查插件更新
        return [:]
    }
}

// MARK: - 插件错误

enum PluginError: Error, LocalizedError {
    case invalidDownloadURL
    case downloadFailed(Error)
    case installationFailed(Error)
    case pluginNotFound(String)
    case invalidPluginFormat
    
    var errorDescription: String? {
        switch self {
        case .invalidDownloadURL:
            return "无效的下载地址"
        case .downloadFailed(let error):
            return "下载失败: \(error.localizedDescription)"
        case .installationFailed(let error):
            return "安装失败: \(error.localizedDescription)"
        case .pluginNotFound(let identifier):
            return "插件未找到: \(identifier)"
        case .invalidPluginFormat:
            return "无效的插件格式"
        }
    }
}
