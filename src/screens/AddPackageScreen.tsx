import React, { useState } from 'react';
import { View, Text, TextInput, ScrollView, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { storage } from '../services/StorageService';
import { createPackage } from '../models/types';
import { parseSms } from '../services/SmsParser';

export function AddPackageScreen() {
  const navigation = useNavigation<any>();
  const [smsText, setSmsText] = useState('');
  const [code, setCode] = useState('');
  const [company, setCompany] = useState('');
  const [address, setAddress] = useState('');
  const [cabinet, setCabinet] = useState('');
  const [phone, setPhone] = useState('');
  const [tracking, setTracking] = useState('');
  const [remark, setRemark] = useState('');

  const handleParse = () => {
    if (!smsText.trim()) {
      Alert.alert('提示', '请粘贴短信内容');
      return;
    }
    const parsed = parseSms('', smsText);
    if (!parsed) {
      Alert.alert('识别失败', '未能从短信中识别取件码，请手动输入');
      return;
    }
    setCode(parsed.pickupCode);
    setCompany(parsed.company);
    setAddress(parsed.address);
    setPhone(parsed.courierPhone);
    setTracking(parsed.trackingNumber);
  };

  const handleSave = async () => {
    const c = code.trim();
    if (!c) {
      Alert.alert('提示', '请输入取件码');
      return;
    }
    const pkg = createPackage({
      pickupCode: c,
      company: company.trim(),
      address: address.trim(),
      cabinetNumber: cabinet.trim(),
      courierPhone: phone.trim(),
      trackingNumber: tracking.trim(),
      remark: remark.trim(),
    });
    await storage.addPackage(pkg);
    Alert.alert('添加成功', '快递已添加到待取件列表', [
      { text: '确定', onPress: () => navigation.goBack() },
    ]);
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {/* SMS parse section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>短信识别</Text>
        <TextInput
          style={styles.smsInput}
          placeholder="粘贴快递短信内容..."
          value={smsText}
          onChangeText={setSmsText}
          multiline
          numberOfLines={4}
          textAlignVertical="top"
        />
        <TouchableOpacity style={styles.parseBtn} onPress={handleParse}>
          <Text style={styles.parseBtnText}>🔍 识别取件码</Text>
        </TouchableOpacity>
      </View>

      {/* Manual input */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>取件码信息</Text>
        <Field label="取件码" value={code} onChangeText={setCode} placeholder="必填" />
        <Field label="快递公司" value={company} onChangeText={setCompany} placeholder="选填" />
        <Field label="取件地址" value={address} onChangeText={setAddress} placeholder="选填" />
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>其他信息</Text>
        <Field label="柜号" value={cabinet} onChangeText={setCabinet} placeholder="选填" />
        <Field label="快递员电话" value={phone} onChangeText={setPhone} placeholder="选填" keyboardType="phone-pad" />
        <Field label="运单号" value={tracking} onChangeText={setTracking} placeholder="选填" />
        <Field label="备注" value={remark} onChangeText={setRemark} placeholder="选填" />
      </View>

      <TouchableOpacity style={styles.saveBtn} onPress={handleSave}>
        <Text style={styles.saveBtnText}>保存</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

function Field({ label, value, onChangeText, placeholder, keyboardType }: {
  label: string; value: string; onChangeText: (t: string) => void;
  placeholder: string; keyboardType?: any;
}) {
  return (
    <View style={styles.field}>
      <Text style={styles.fieldLabel}>{label}</Text>
      <TextInput
        style={styles.fieldInput}
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        keyboardType={keyboardType}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F5F5' },
  content: { padding: 16, paddingBottom: 40 },
  section: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
  },
  sectionTitle: { fontSize: 16, fontWeight: '600', marginBottom: 12, color: '#333' },
  smsInput: {
    borderWidth: 1,
    borderColor: '#E0E0E0',
    borderRadius: 8,
    padding: 12,
    fontSize: 14,
    minHeight: 80,
    marginBottom: 12,
  },
  parseBtn: {
    backgroundColor: '#F57C00',
    borderRadius: 8,
    paddingVertical: 12,
    alignItems: 'center',
  },
  parseBtnText: { color: '#fff', fontWeight: '600', fontSize: 15 },
  field: {
    flexDirection: 'row',
    alignItems: 'center',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#EEE',
    paddingVertical: 10,
  },
  fieldLabel: { width: 80, fontSize: 14, color: '#666' },
  fieldInput: { flex: 1, fontSize: 14, color: '#333', padding: 0 },
  saveBtn: {
    backgroundColor: '#F57C00',
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
  },
  saveBtnText: { color: '#fff', fontSize: 16, fontWeight: '600' },
});
