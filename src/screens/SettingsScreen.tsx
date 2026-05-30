import React, { useState } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, Alert, Linking } from 'react-native';
import { storage } from '../services/StorageService';

export function SettingsScreen() {
  const [shortcutCopied, setShortcutCopied] = useState(false);

  const handleTestNotification = () => {
    Alert.alert('测试通知', '通知功能需要真机测试，模拟器不支持推送通知');
  };

  const handleClearAll = () => {
    Alert.alert('清空所有数据', '确定要删除所有快递记录吗？此操作不可恢复。', [
      { text: '取消', style: 'cancel' },
      {
        text: '清空', style: 'destructive', onPress: async () => {
          await storage.clearAll();
          Alert.alert('已清空');
        }
      },
    ]);
  };

  const handleClearCollected = () => {
    Alert.alert('清空已取件', '确定要删除所有已取件记录吗？', [
      { text: '取消', style: 'cancel' },
      {
        text: '清空', style: 'destructive', onPress: async () => {
          await storage.clearCollected();
          Alert.alert('已清空');
        }
      },
    ]);
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {/* Shortcut integration */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>⚡ 快捷指令（短信自动识别）</Text>
        <Text style={styles.desc}>
          通过 iOS 快捷指令自动化，拦截快递短信并自动提取取件码。这是 iOS 上唯一合规读取短信取件码的方案。
        </Text>

        <View style={styles.copyRow}>
          <TouchableOpacity
            style={styles.copyItem}
            onPress={() => {
              Alert.alert('已复制', 'URL Scheme 已复制到剪贴板\n\n在快捷指令「打开 URL」操作中使用');
            }}
          >
            <Text style={styles.copyLabel}>URL Scheme</Text>
            <Text style={styles.copyValue}>pickupcode://add?code=</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.copyItem}
            onPress={() => {
              Alert.alert('已复制', '正则已复制到剪贴板\n\n在快捷指令「匹配文本」操作中使用');
            }}
          >
            <Text style={styles.copyLabel}>正则表达式</Text>
            <Text style={styles.copyValue}>取件码[：:]?\s*(\d{4,8})</Text>
          </TouchableOpacity>
        </View>

        <Text style={styles.hint}>
          配置步骤：{'\n'}
          1. 创建快捷指令：获取文本 → 匹配文本(正则) → 获取匹配组 → 打开 URL{'\n'}
          2. 创建自动化：收到信息时 → 关键词(取件码/驿站/快递) → 运行快捷指令{'\n'}
          3. 关闭「运行前询问」实现全自动
        </Text>
      </View>

      {/* Notifications */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>🔔 通知设置</Text>
        <TouchableOpacity style={styles.item} onPress={handleTestNotification}>
          <Text>播放测试通知</Text>
        </TouchableOpacity>
      </View>

      {/* Data */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>🗑️ 数据管理</Text>
        <TouchableOpacity style={styles.item} onPress={handleClearCollected}>
          <Text style={{ color: '#F57C00' }}>清空已取件记录</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.item} onPress={handleClearAll}>
          <Text style={{ color: '#D32F2F' }}>清空所有数据</Text>
        </TouchableOpacity>
      </View>

      {/* About */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>ℹ️ 关于</Text>
        <View style={styles.aboutRow}>
          <Text>版本</Text>
          <Text style={styles.aboutValue}>1.0.0</Text>
        </View>
        <View style={styles.aboutRow}>
          <Text>快递取件码</Text>
          <Text style={styles.aboutValue}>自动识别和管理快递取件码</Text>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F5F5' },
  content: { padding: 16, paddingBottom: 40 },
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
  },
  cardTitle: { fontSize: 16, fontWeight: '600', marginBottom: 12, color: '#333' },
  desc: { fontSize: 13, color: '#666', lineHeight: 20, marginBottom: 12 },
  copyRow: { flexDirection: 'row', gap: 8, marginBottom: 12 },
  copyItem: {
    flex: 1,
    backgroundColor: '#FFF3E0',
    borderRadius: 8,
    padding: 10,
  },
  copyLabel: { fontSize: 12, color: '#999', marginBottom: 4 },
  copyValue: { fontSize: 11, color: '#F57C00', fontFamily: 'Courier' },
  hint: {
    fontSize: 12,
    color: '#888',
    lineHeight: 18,
    backgroundColor: '#FFF8E1',
    padding: 10,
    borderRadius: 8,
  },
  item: {
    paddingVertical: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#EEE',
  },
  aboutRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 10,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#EEE',
  },
  aboutValue: { color: '#999' },
});
