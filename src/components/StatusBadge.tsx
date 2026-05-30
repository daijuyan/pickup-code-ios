import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { PackageStatus } from '../models/types';

export function StatusBadge({ status }: { status: PackageStatus }) {
  const isPending = status === 'pending';
  return (
    <View style={[styles.badge, { backgroundColor: isPending ? '#FFF3E0' : '#E8F5E9' }]}>
      <Text style={[styles.text, { color: isPending ? '#F57C00' : '#388E3C' }]}>
        {isPending ? '待取件' : '已取件'}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  badge: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 6 },
  text: { fontSize: 12, fontWeight: '600' },
});
