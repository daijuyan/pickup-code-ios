interface ParsedSms {
  pickupCode: string;
  company: string;
  address: string;
  courierPhone: string;
  trackingNumber: string;
}

interface CourierRule {
  companyName: string;
  keywords: string[];
  codePatterns: RegExp[];
}

const rules: CourierRule[] = [
  { companyName: '菜鸟驿站', keywords: ['菜鸟', 'cainiao'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/, /验证码[：:]?\s*(\d{4,8})/] },
  { companyName: '丰巢', keywords: ['丰巢', 'fengchao'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/, /凭[码碼][：:]?\s*(\d{4,8})/] },
  { companyName: '妈妈驿站', keywords: ['妈妈驿站'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/] },
  { companyName: '兔喜生活', keywords: ['兔喜'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/] },
  { companyName: '心甜智能柜', keywords: ['心甜'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/] },
  { companyName: '顺丰速运', keywords: ['顺丰', 'shunfeng', 'SF'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/, /验证码[：:]?\s*(\d{4,8})/] },
  { companyName: '中通快递', keywords: ['中通', 'zhongtong', 'ZTO'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/] },
  { companyName: '圆通速递', keywords: ['圆通', 'yuantong', 'YTO'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/] },
  { companyName: '申通快递', keywords: ['申通', 'shentong', 'STO'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/] },
  { companyName: '韵达快递', keywords: ['韵达', 'yunda', 'YD'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/] },
  { companyName: '京东物流', keywords: ['京东', 'jd'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/] },
  { companyName: '极兔速递', keywords: ['极兔', 'jtexpress'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/] },
  { companyName: '邮政EMS', keywords: ['邮政', 'EMS', 'ems'], codePatterns: [/取件码[：:]?\s*(\d{4,8})/] },
];

const generalPatterns: RegExp[] = [
  /取件码[：:]?\s*(\d{4,8})/,
  /取货码[：:]?\s*(\d{4,8})/,
  /验证码[：:]?\s*(\d{4,8})/,
  /凭[码碼][：:]?\s*(\d{4,8})/,
  /提取码[：:]?\s*([A-Za-z0-9]{4,8})/,
  /取件码[为是]([A-Za-z0-9]{4,8})/,
];

function isPhoneNumber(code: string): boolean {
  const digits = code.replace(/\D/g, '');
  return digits.length >= 10 && digits.length <= 12 && digits.startsWith('1');
}

export function parseSms(sender: string, body: string): ParsedSms | null {
  const lower = body.toLowerCase();
  const senderLower = sender.toLowerCase();

  // Match courier
  let company = '';
  let matchedRule: CourierRule | null = null;
  for (const rule of rules) {
    if (rule.keywords.some(k => lower.includes(k.toLowerCase()) || senderLower.includes(k.toLowerCase()))) {
      company = rule.companyName;
      matchedRule = rule;
      break;
    }
  }

  // Extract code
  let code = '';
  if (matchedRule) {
    for (const p of matchedRule.codePatterns) {
      const m = body.match(p);
      if (m) { code = m[1]; break; }
    }
  }
  if (!code) {
    for (const p of generalPatterns) {
      const m = body.match(p);
      if (m) { code = m[1]; break; }
    }
  }
  if (!code || isPhoneNumber(code)) return null;

  // Extract address
  let address = '';
  const addrPatterns = [/地址[：:]?\s*(.+?)(?=，|。|$)/, /地点[：:]?\s*(.+?)(?=，|。|$)/];
  for (const p of addrPatterns) {
    const m = body.match(p);
    if (m) { address = m[1].trim(); break; }
  }

  // Extract phone
  let phone = '';
  const phonePatterns = [/电话[：:]?\s*(1[3-9]\d{9})/, /(1[3-9]\d{9})/];
  for (const p of phonePatterns) {
    const m = body.match(p);
    if (m) { phone = m[1]; break; }
  }

  // Extract tracking
  let tracking = '';
  const trackPatterns = [/单号[：:]?\s*([A-Za-z0-9]{10,20})/, /运单[：:]?\s*([A-Za-z0-9]{10,20})/];
  for (const p of trackPatterns) {
    const m = body.match(p);
    if (m) { tracking = m[1]; break; }
  }

  return {
    pickupCode: code,
    company: company || '快递',
    address,
    courierPhone: phone,
    trackingNumber: tracking,
  };
}
