export type PackageStatus = 'pending' | 'collected';

export interface ExpressPackage {
  id: string;
  pickupCode: string;
  company: string;
  address: string;
  cabinetNumber: string;
  courierPhone: string;
  trackingNumber: string;
  status: PackageStatus;
  pickupDeadline?: number;
  remark: string;
  receivedTime: number;
  collectedTime?: number;
  smsSender: string;
  smsBody: string;
}

export function createPackage(params: Partial<ExpressPackage> & { pickupCode: string }): ExpressPackage {
  return {
    id: Date.now().toString(36) + Math.random().toString(36).slice(2, 8),
    pickupCode: params.pickupCode,
    company: params.company || '',
    address: params.address || '',
    cabinetNumber: params.cabinetNumber || '',
    courierPhone: params.courierPhone || '',
    trackingNumber: params.trackingNumber || '',
    status: params.status || 'pending',
    pickupDeadline: params.pickupDeadline,
    remark: params.remark || '',
    receivedTime: params.receivedTime || Date.now(),
    collectedTime: params.collectedTime,
    smsSender: params.smsSender || '',
    smsBody: params.smsBody || '',
  };
}
