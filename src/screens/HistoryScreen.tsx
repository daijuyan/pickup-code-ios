import React, { useState, useCallback } from 'react';
import { View, FlatList, TextInput, StyleSheet, Alert } from 'react-native';
import { useFocusEffect, useNavigation } from '@react-navigation/native';
import { storage } from '../services/StorageService';
import { ExpressPackage } from '../models/types';
import { PackageCard } from '../components/PackageCard';
import { EmptyState } from '../components/EmptyState';

export function HistoryScreen() {
  const navigation = useNavigation<any>();
  const [packages, setPackages] = useState<ExpressPackage[]>([]);
  const [search, setSearch] = useState('');

  const refresh = useCallback(async () => {
    await storage.load();
    setPackages(storage.getCollected());
  }, []);

  useFocusEffect(useCallback(() => { refresh(); }, [refresh]));

  const filtered = search
    ? packages.filter(p =>
        p.pickupCode.includes(search) ||
        p.company.includes(search) ||
        p.address.includes(search)
      )
    : packages;

  return (
    <View style={styles.container}>
      <View style={styles.searchWrap}>
        <TextInput
          style={styles.search}
          placeholder="搜索已取件记录"
          value={search}
          onChangeText={setSearch}
          clearButtonMode="while-editing"
        />
      </View>

      {filtered.length === 0 ? (
        <EmptyState
          icon="✅"
          title="暂无已取件记录"
          subtitle="取件后的快递会出现在这里"
        />
      ) : (
        <FlatList
          data={filtered}
          keyExtractor={item => item.id}
          renderItem={({ item }) => (
            <PackageCard
              pkg={item}
              onPress={() => navigation.navigate('Detail', { pkg: item, readOnly: true })}
              showCollectedTime
            />
          )}
          contentContainerStyle={styles.list}
          onRefresh={refresh}
          refreshing={false}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F5F5' },
  searchWrap: { padding: 16, paddingBottom: 8 },
  search: {
    backgroundColor: '#fff',
    borderRadius: 10,
    paddingHorizontal: 14,
    paddingVertical: 10,
    fontSize: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.04,
    shadowRadius: 2,
    elevation: 1,
  },
  list: { paddingHorizontal: 16, paddingBottom: 100 },
});
