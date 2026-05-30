import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { StatusBar } from 'expo-status-bar';

// 全局错误捕获
let globalErrors: string[] = [];
const originalConsoleError = console.error;
console.error = (...args: any[]) => {
  globalErrors.push(args.map(a => String(a)).join(' '));
  originalConsoleError(...args);
};

// 捕获未处理的 JS 错误
ErrorUtils.setGlobalHandler((error: any, isFatal?: boolean) => {
  globalErrors.push(`[${isFatal ? 'FATAL' : 'ERROR'}] ${error?.message || String(error)}\n${error?.stack || ''}`);
});

class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error: string }
> {
  state = { hasError: false, error: '' };

  static getDerivedStateFromError(error: any) {
    return { hasError: true, error: String(error?.message || error) };
  }

  componentDidCatch(error: any, info: any) {
    globalErrors.push(`[Boundary] ${error?.message}\n${info?.componentStack}`);
  }

  render() {
    if (this.state.hasError) {
      return (
        <View style={styles.container}>
          <Text style={styles.title}>组件错误</Text>
          <Text style={styles.errorText}>{this.state.error}</Text>
          <ScrollView style={styles.logBox}>
            {globalErrors.map((e, i) => (
              <Text key={i} style={styles.logText}>{e}</Text>
            ))}
          </ScrollView>
        </View>
      );
    }
    return this.props.children;
  }
}

function MainApp() {
  const [errors, setErrors] = React.useState<string[]>([]);
  const [loaded, setLoaded] = React.useState(false);

  React.useEffect(() => {
    try {
      // 逐个测试模块加载
      const testModules = async () => {
        const results: string[] = [];

        try {
          const AsyncStorage = (await import('@react-native-async-storage/async-storage')).default;
          results.push('AsyncStorage: OK');
        } catch (e: any) {
          results.push(`AsyncStorage FAIL: ${e.message}`);
        }

        try {
          const { NavigationContainer } = await import('@react-navigation/native');
          results.push('NavigationContainer: OK');
        } catch (e: any) {
          results.push(`NavigationContainer FAIL: ${e.message}`);
        }

        try {
          const { createBottomTabNavigator } = await import('@react-navigation/bottom-tabs');
          results.push('BottomTabs: OK');
        } catch (e: any) {
          results.push(`BottomTabs FAIL: ${e.message}`);
        }

        try {
          const { createNativeStackNavigator } = await import('@react-navigation/native-stack');
          results.push('NativeStack: OK');
        } catch (e: any) {
          results.push(`NativeStack FAIL: ${e.message}`);
        }

        try {
          const { SafeAreaProvider } = await import('react-native-safe-area-context');
          results.push('SafeArea: OK');
        } catch (e: any) {
          results.push(`SafeArea FAIL: ${e.message}`);
        }

        try {
          require('react-native-screens');
          results.push('Screens: OK');
        } catch (e: any) {
          results.push(`Screens FAIL: ${e.message}`);
        }

        results.push(`\nReact: ${React.version}`);
        results.push(`Time: ${new Date().toLocaleString()}`);
        results.push(`Global errors: ${globalErrors.length}`);

        if (globalErrors.length > 0) {
          results.push('\n--- Global Errors ---');
          results.push(...globalErrors.slice(-5));
        }

        setErrors(results);
        setLoaded(true);
      };

      testModules();
    } catch (e: any) {
      setErrors([`启动失败: ${e.message}`, String(e.stack)]);
      setLoaded(true);
    }
  }, []);

  return (
    <View style={styles.container}>
      <StatusBar style="dark" />
      <Text style={styles.title}>快递取件码 - 诊断</Text>
      <Text style={styles.subtitle}>
        {loaded ? '诊断完成' : '正在检测...'}
      </Text>
      <ScrollView style={styles.logBox}>
        {errors.map((e, i) => (
          <Text key={i} style={[
            styles.logText,
            e.includes('FAIL') && styles.errorText,
          ]}>
            {e}
          </Text>
        ))}
      </ScrollView>
    </View>
  );
}

export default function App() {
  return (
    <ErrorBoundary>
      <MainApp />
    </ErrorBoundary>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, paddingTop: 60, paddingHorizontal: 20, backgroundColor: '#F5F5F5' },
  title: { fontSize: 22, fontWeight: '700', color: '#F57C00', marginBottom: 4 },
  subtitle: { fontSize: 15, color: '#333', marginBottom: 16 },
  logBox: { flex: 1, backgroundColor: '#fff', borderRadius: 8, padding: 12 },
  logText: { fontSize: 12, color: '#333', marginBottom: 6, fontFamily: 'Courier' },
  errorText: { color: '#D32F2F', fontWeight: '600' },
});
