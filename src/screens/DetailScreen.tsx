import React, { useState } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import * as Clipboard from 'expo-clipboard';
import { useRoute, useNavigation } from '@react-navigation/native';
import { ExpressPackage } from '../models/types';
import { StatusBadge } from '../components/StatusBadge';
import { storage } from '../services/StorageService';

function formatDate(ts: number): string {
  return new Date(ts).toLocaleString('zh-CN', {
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit',
  });
}

export function DetailScreen() {
  const route = useRoute<any>();
  const navigation = useNavigation();
  const { pkg, readOnly } = route.params as { pkg: ExpressPackage; readOnly?: boolean };
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    await Clipboard.setStringAsync(pkg.pickupCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  };

  const handleCollect = () => {
    Alert.alert('确认取件', `标记快递 ${pkg.pickupCode} 为已取件？`, [
      { text: '取消', style: 'cancel' },
      {
        text: '确认', onPress: async () => {
          await storage.markAsCollected(pkg);
          navigation.goBack();
        }
      },
    ]);
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {/* Big code */}
      <View style={styles.codeSection}>
        <Text style={styles.label}>取件码</Text>
        <Text style={styles.code}>{pkg.pickupCode}</Text>
        <TouchableOpacity style={styles.copyBtn} onPress={handleCopy}>
          <Text style={styles.copyText}>{copied ? '已复制 ✓' : '📋 复制取件码'}</Text>
        </TouchableOpacity>
      </View>

      {/* Info */}
      <View style={styles.infoCard}>
        {pkg.company ? <InfoRow icon="📦" label="快递公司" value={pkg.company} /> : null}
        {pkg.address ? <InfoRow icon="📍" label="取件地址" value={pkg.address} /> : null}
        {pkg.cabinetNumber ? <InfoRow icon="🔒" label="柜号" value={pkg.cabinetNumber} /> : null}
        {pkg.courierPhone ? <InfoRow icon="📞" label="快递员电话" value={pkg.courierPhone} /> : null}
        {pkg.trackingNumber ? <InfoRow icon="🏷️" label="运单号" value={pkg.trackingNumber} /> : null}
        <InfoRow icon="🕐" label="收到时间" value={formatDate(pkg.receivedTime)} />
        {pkg.collectedTime ? (
          <InfoRow icon="✅" label="取件时间" value={formatDate(pkg.collectedTime)} valueColor="#388E3C" />
        ) : null}
        {pkg.remark ? <InfoRow icon="📝" label="备注" value={pkg.remark} /> : null}
      </View>

      {/* Status */}
      <View style={styles.statusRow}>
        <StatusBadge status={pkg.status} />
      </View>

      {/* Collect button */}
      {pkg.status === 'pending' && !readOnly && (
        <TouchableOpacity style={styles.collectBtn} onPress={handleCollect}>
          <Text style={styles.collectBtnText}>✅ 标记为已取件</Text>
        </TouchableOpacity>
      )}
    </ScrollView>
  );
}

function InfoRow({ icon, label, value, valueColor }: {
  icon: string; label: string; value: string; valueColor?: string;
}) {
  return (
    <View style={styles.infoRow}>
      <Text style={styles.infoIcon}>{icon}</Text>
      <Text style={styles.infoLabel}>{label}</Text>
      <Text style={[styles.infoValue, valueColor ? { color: valueColor } : null]} numberOfLines={3}>
        {value}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F5F5' },
  content: { padding: 16, paddingBottom: 40 },
  codeSection: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 24,
    alignItems: 'center',
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 4,
    elevation: 2,
  },
  label: { fontSize: 14, color: '#999', marginBottom: 8 },
  code: { fontSize: 56, fontWeight: 'bold', color: '#F57C00' },
  copyBtn: {
    marginTop: 16,
    backgroundColor: '#FFF3E0',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 10,
  },
  copyText: { color: '#F57C00', fontWeight: '600', fontSize: 15 },
  infoCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.04,
    shadowRadius: 2,
    elevation: 1,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#EEE',
  },
  infoIcon: { fontSize: 18, width: 28, textAlign: 'center' },
  infoLabel: { fontSize: 14, color: '#666', width: 80 },
  infoValue: { flex: 1, fontSize: 14, color: '#333', textAlign: 'right' },
  statusRow: { flexDirection: 'row', marginBottom: 16 },
  collectBtn: {
    backgroundColor: '#388E3C',
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
  },
  collectBtnText: { color: '#fff', fontSize: 16, fontWeight: '600' },
});
