import AsyncStorage from '@react-native-async-storage/async-storage';
import { ExpressPackage, PackageStatus } from '../models/types';

const STORAGE_KEY = 'pickup_packages';

class StorageService {
  private packages: ExpressPackage[] = [];

  async load(): Promise<ExpressPackage[]> {
    try {
      const data = await AsyncStorage.getItem(STORAGE_KEY);
      this.packages = data ? JSON.parse(data) : [];
    } catch {
      this.packages = [];
    }
    return this.packages;
  }

  private async save(): Promise<void> {
    await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(this.packages));
  }

  async addPackage(pkg: ExpressPackage): Promise<void> {
    this.packages.unshift(pkg);
    await this.save();
  }

  async updatePackage(pkg: ExpressPackage): Promise<void> {
    const idx = this.packages.findIndex(p => p.id === pkg.id);
    if (idx >= 0) {
      this.packages[idx] = pkg;
      await this.save();
    }
  }

  async markAsCollected(pkg: ExpressPackage): Promise<void> {
    pkg.status = 'collected';
    pkg.collectedTime = Date.now();
    await this.updatePackage(pkg);
  }

  async deletePackage(id: string): Promise<void> {
    this.packages = this.packages.filter(p => p.id !== id);
    await this.save();
  }

  async clearAll(): Promise<void> {
    this.packages = [];
    await this.save();
  }

  async clearCollected(): Promise<void> {
    this.packages = this.packages.filter(p => p.status !== 'collected');
    await this.save();
  }

  getPending(): ExpressPackage[] {
    return this.packages
      .filter(p => p.status === 'pending')
      .sort((a, b) => b.receivedTime - a.receivedTime);
  }

  getCollected(): ExpressPackage[] {
    return this.packages
      .filter(p => p.status === 'collected')
      .sort((a, b) => (b.collectedTime || 0) - (a.collectedTime || 0));
  }
}

export const storage = new StorageService();
