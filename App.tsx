import React from 'react';
import { TouchableOpacity, Text } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { StatusBar } from 'expo-status-bar';
import { HomeScreen } from './src/screens/HomeScreen';
import { HistoryScreen } from './src/screens/HistoryScreen';
import { DetailScreen } from './src/screens/DetailScreen';
import { AddPackageScreen } from './src/screens/AddPackageScreen';
import { SettingsScreen } from './src/screens/SettingsScreen';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

function HomeTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: '#F57C00',
        tabBarInactiveTintColor: '#999',
        headerStyle: { backgroundColor: '#fff' },
        headerTitleStyle: { fontWeight: '600' },
      }}
    >
      <Tab.Screen
        name="HomeTab"
        component={HomeScreen}
        options={({ navigation }) => ({
          title: '待取件',
          tabBarLabel: '待取件',
          tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>📦</Text>,
          headerRight: () => (
            <TouchableOpacity
              style={{ marginRight: 16 }}
              onPress={() => navigation.navigate('Add' as never)}
            >
              <Text style={{ fontSize: 24, color: '#F57C00' }}>+</Text>
            </TouchableOpacity>
          ),
        })}
      />
      <Tab.Screen
        name="HistoryTab"
        component={HistoryScreen}
        options={{
          title: '已取件',
          tabBarLabel: '已取件',
          tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>✅</Text>,
        }}
      />
      <Tab.Screen
        name="SettingsTab"
        component={SettingsScreen}
        options={{
          title: '设置',
          tabBarLabel: '设置',
          tabBarIcon: ({ color }) => <Text style={{ fontSize: 20, color }}>⚙️</Text>,
        }}
      />
    </Tab.Navigator>
  );
}

export default function App() {
  return (
    <NavigationContainer>
      <StatusBar style="dark" />
      <Stack.Navigator>
        <Stack.Screen
          name="Main"
          component={HomeTabs}
          options={{ headerShown: false }}
        />
        <Stack.Screen
          name="Detail"
          component={DetailScreen}
          options={{ title: '快递详情', headerBackTitle: '返回' }}
        />
        <Stack.Screen
          name="Add"
          component={AddPackageScreen}
          options={{ title: '添加快递', headerBackTitle: '返回' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
