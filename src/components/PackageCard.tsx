import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { ExpressPackage } from '../models/types';
import { StatusBadge } from './StatusBadge';

function formatDate(ts: number): string {
  const d = new Date(ts);
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  const h = String(d.getHours()).padStart(2, '0');
  const min = String(d.getMinutes()).padStart(2, '0');
  return `${m}-${day} ${h}:${min}`;
}

interface Props {
  pkg: ExpressPackage;
  onPress: () => void;
  onCollect?: () => void;
  showCollectedTime?: boolean;
}

export function PackageCard({ pkg, onPress, onCollect, showCollectedTime }: Props) {
  return (
    <TouchableOpacity style={styles.card} onPress={onPress} activeOpacity={0.7}>
      <View style={styles.header}>
        <Text style={styles.code}>{pkg.pickupCode}</Text>
        {pkg.status === 'pending' && onCollect && (
          <TouchableOpacity style={styles.collectBtn} onPress={onCollect}>
            <Text style={styles.collectText}>取件</Text>
          </TouchableOpacity>
        )}
      </View>

      {pkg.company ? (
        <Text style={styles.info}>📦 {pkg.company}</Text>
      ) : null}

      {pkg.address ? (
        <Text style={styles.info} numberOfLines={2}>📍 {pkg.address}</Text>
      ) : null}

      <View style={styles.footer}>
        <Text style={styles.date}>{formatDate(pkg.receivedTime)}</Text>
        {showCollectedTime && pkg.collectedTime ? (
          <Text style={styles.collectedDate}>取件: {formatDate(pkg.collectedTime)}</Text>
        ) : null}
        <StatusBadge status={pkg.status} />
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 4,
    elevation: 2,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  code: { fontSize: 28, fontWeight: 'bold', color: '#F57C00' },
  collectBtn: {
    backgroundColor: '#E8F5E9',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
  },
  collectText: { color: '#388E3C', fontWeight: '600', fontSize: 14 },
  info: { fontSize: 14, color: '#666', marginBottom: 4 },
  footer: { flexDirection: 'row', alignItems: 'center', marginTop: 8, gap: 8 },
  date: { fontSize: 12, color: '#999' },
  collectedDate: { fontSize: 12, color: '#388E3C' },
});
