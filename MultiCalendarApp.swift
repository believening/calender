//
//  MultiCalendarApp.swift
//  MultiCalendarApp
//
//  应用入口
//

import SwiftUI

@main
struct MultiCalendarApp: App {
    @StateObject private var pluginManager = PluginManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    init() {
        // 初始化插件系统
        setupPlugins()
        
        // 请求通知权限
        Task {
            await notificationManager.requestNotificationPermission()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 调度所有提醒
                    notificationManager.scheduleAllReminders()
                }
        }
    }
    
    private func setupPlugins() {
        // 注册农历插件（内置）
        let lunarPlugin = LunarCalendarPlugin()
        pluginManager.registerPlugin(lunarPlugin)
        
        // 注册藏历插件（动态加载）
        // 在实际应用中，这里应该从服务器下载并加载
        // POC阶段，我们直接注册
        let tibetanPlugin = TibetanCalendarPlugin()
        pluginManager.registerPlugin(tibetanPlugin)
    }
}
