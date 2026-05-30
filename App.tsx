import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { StatusBar } from 'expo-status-bar';

export default function App() {
  const [status, setStatus] = useState('加载中...');
  const [details, setDetails] = useState<string[]>([]);

  const log = (msg: string) => {
    setDetails(prev => [...prev, `[${new Date().toLocaleTimeString()}] ${msg}`]);
  };

  useEffect(() => {
    try {
      log('App 启动成功');
      log(`React 版本: ${React.version}`);

      // Test AsyncStorage
      (async () => {
        try {
          const AsyncStorage = (await import('@react-native-async-storage/async-storage')).default;
          await AsyncStorage.setItem('test', 'hello');
          const val = await AsyncStorage.getItem('test');
          log(`AsyncStorage 测试: ${val}`);
          await AsyncStorage.removeItem('test');
        } catch (e: any) {
          log(`AsyncStorage 错误: ${e.message}`);
        }

        // Test Navigation
        try {
          const nav = await import('@react-navigation/native');
          log(`@react-navigation/native 加载成功`);
        } catch (e: any) {
          log(`Navigation 加载错误: ${e.message}`);
        }

        // Test Bottom Tabs
        try {
          const tabs = await import('@react-navigation/bottom-tabs');
          log(`@react-navigation/bottom-tabs 加载成功`);
        } catch (e: any) {
          log(`Bottom Tabs 加载错误: ${e.message}`);
        }

        // Test Native Stack
        try {
          const stack = await import('@react-navigation/native-stack');
          log(`@react-navigation/native-stack 加载成功`);
        } catch (e: any) {
          log(`Native Stack 加载错误: ${e.message}`);
        }

        // Test SafeArea
        try {
          const safe = await import('react-native-safe-area-context');
          log(`safe-area-context 加载成功`);
        } catch (e: any) {
          log(`SafeArea 加载错误: ${e.message}`);
        }

        // Test Screens
        try {
          const screens = await import('react-native-screens');
          log(`react-native-screens 加载成功`);
        } catch (e: any) {
          log(`Screens 加载错误: ${e.message}`);
        }

        setStatus('所有模块测试完成');
      })();
    } catch (e: any) {
      log(`启动错误: ${e.message}`);
      setStatus('启动出错');
    }
  }, []);

  return (
    <View style={styles.container}>
      <StatusBar style="dark" />
      <Text style={styles.title}>快递取件码</Text>
      <Text style={styles.status}>{status}</Text>
      <ScrollView style={styles.logContainer}>
        {details.map((d, i) => (
          <Text key={i} style={styles.logText}>{d}</Text>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, paddingTop: 60, paddingHorizontal: 20, backgroundColor: '#F5F5F5' },
  title: { fontSize: 24, fontWeight: '700', color: '#F57C00', marginBottom: 8 },
  status: { fontSize: 16, color: '#333', marginBottom: 16, fontWeight: '600' },
  logContainer: { flex: 1, backgroundColor: '#fff', borderRadius: 8, padding: 12 },
  logText: { fontSize: 13, color: '#555', marginBottom: 6, fontFamily: 'Courier' },
});
