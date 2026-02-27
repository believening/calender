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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // 初始化插件系统
                    setupPlugins()
                    
                    // 请求通知权限
                    await notificationManager.requestNotificationPermission()
                    
                    // 调度所有提醒
                    notificationManager.scheduleAllReminders()
                }
        }
    }
    
    private func setupPlugins() {
        // 注册农历插件（内置）
        let lunarPlugin = LunarCalendarPlugin()
        pluginManager.registerPlugin(lunarPlugin)
        
        // 注册藏历插件
        let tibetanPlugin = TibetanCalendarPlugin()
        pluginManager.registerPlugin(tibetanPlugin)
    }
}
