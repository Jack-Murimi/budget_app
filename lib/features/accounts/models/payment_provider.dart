enum PaymentProviderGroup { bank, mobileMoney, cash }

class PaymentProvider {
  final String id;
  final String name;
  final String subtitle;
  final String type;
  final String primaryColorHex;
  final String secondaryColorHex;
  final String accentColorHex;
  final String logoAsset;
  final PaymentProviderGroup group;
  final bool fullBleedBadge;

  const PaymentProvider({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.type,
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.accentColorHex,
    required this.logoAsset,
    required this.group,
    this.fullBleedBadge = false,
  });

  bool get isSvg => logoAsset.toLowerCase().endsWith('.svg');
}

abstract final class PaymentProviders {
  static const mpesa = PaymentProvider(
    id: 'brand_mpesa',
    name: 'M-Pesa',
    subtitle: 'Safaricom M-Pesa',
    type: 'mpesa',
    primaryColorHex: '#008A45',
    secondaryColorHex: '#00562B',
    accentColorHex: '#DE1E23',
    logoAsset: 'assets/brands/mpesa.png',
    group: PaymentProviderGroup.mobileMoney,
  );

  static const airtel = PaymentProvider(
    id: 'brand_airtel',
    name: 'Airtel Money',
    subtitle: 'Airtel Kenya',
    type: 'airtel',
    primaryColorHex: '#C90000',
    secondaryColorHex: '#7E0000',
    accentColorHex: '#FFFFFF',
    logoAsset: 'assets/brands/airtel.svg',
    group: PaymentProviderGroup.mobileMoney,
  );

  static const tkash = PaymentProvider(
    id: 'brand_tkash',
    name: 'T-Kash',
    subtitle: 'Telkom Kenya',
    type: 'mobile',
    primaryColorHex: '#007799',
    secondaryColorHex: '#16324F',
    accentColorHex: '#FFEB00',
    logoAsset: 'assets/brands/tkash.jpg',
    group: PaymentProviderGroup.mobileMoney,
    fullBleedBadge: true,
  );

  static const cash = PaymentProvider(
    id: 'brand_cash',
    name: 'Cash',
    subtitle: 'Physical Cash Wallet',
    type: 'cash',
    primaryColorHex: '#2E7D32',
    secondaryColorHex: '#1B5E20',
    accentColorHex: '#A5D6A7',
    logoAsset: 'assets/brands/cash.svg',
    group: PaymentProviderGroup.cash,
    fullBleedBadge: true,
  );

  static const equity = PaymentProvider(
    id: 'brand_equity',
    name: 'Equity Bank',
    subtitle: 'Equity Bank Kenya',
    type: 'bank',
    primaryColorHex: '#A32A29',
    secondaryColorHex: '#631413',
    accentColorHex: '#DAA05F',
    logoAsset: 'assets/brands/equity.png',
    group: PaymentProviderGroup.bank,
  );

  static const kcb = PaymentProvider(
    id: 'brand_kcb',
    name: 'KCB Bank',
    subtitle: 'Kenya Commercial Bank',
    type: 'bank',
    primaryColorHex: '#003D4C',
    secondaryColorHex: '#002129',
    accentColorHex: '#7CC142',
    logoAsset: 'assets/brands/kcb.png',
    group: PaymentProviderGroup.bank,
    fullBleedBadge: true,
  );

  static const coop = PaymentProvider(
    id: 'brand_coop',
    name: 'Co-op Bank',
    subtitle: 'Co-operative Bank of Kenya',
    type: 'bank',
    primaryColorHex: '#00533D',
    secondaryColorHex: '#003325',
    accentColorHex: '#82AD37',
    logoAsset: 'assets/brands/coop.webp',
    group: PaymentProviderGroup.bank,
  );

  static const ncba = PaymentProvider(
    id: 'brand_ncba',
    name: 'NCBA Bank',
    subtitle: 'NCBA Bank Kenya',
    type: 'bank',
    primaryColorHex: '#164679',
    secondaryColorHex: '#0A2340',
    accentColorHex: '#B5D334',
    logoAsset: 'assets/brands/ncba.png',
    group: PaymentProviderGroup.bank,
    fullBleedBadge: true,
  );

  static const absa = PaymentProvider(
    id: 'brand_absa',
    name: 'Absa Bank',
    subtitle: 'Absa Bank Kenya',
    type: 'bank',
    primaryColorHex: '#A90C2B',
    secondaryColorHex: '#640417',
    accentColorHex: '#DAA05F',
    logoAsset: 'assets/brands/absa.svg',
    group: PaymentProviderGroup.bank,
  );

  static const scb = PaymentProvider(
    id: 'brand_scb',
    name: 'Standard Chartered',
    subtitle: 'Standard Chartered Kenya',
    type: 'bank',
    primaryColorHex: '#046AD6',
    secondaryColorHex: '#023370',
    accentColorHex: '#38D200',
    logoAsset: 'assets/brands/scb.svg',
    group: PaymentProviderGroup.bank,
  );

  static const im = PaymentProvider(
    id: 'brand_im',
    name: 'I&M Bank',
    subtitle: 'I&M Bank Kenya',
    type: 'bank',
    primaryColorHex: '#003366',
    secondaryColorHex: '#001A36',
    accentColorHex: '#BD2426',
    logoAsset: 'assets/brands/im.png',
    group: PaymentProviderGroup.bank,
  );

  static const stanbic = PaymentProvider(
    id: 'brand_stanbic',
    name: 'Stanbic Bank',
    subtitle: 'Stanbic Bank Kenya',
    type: 'bank',
    primaryColorHex: '#0047B3',
    secondaryColorHex: '#00225B',
    accentColorHex: '#1CA9F8',
    logoAsset: 'assets/brands/stanbic.png',
    group: PaymentProviderGroup.bank,
  );

  static const dtb = PaymentProvider(
    id: 'brand_dtb',
    name: 'DTB Bank',
    subtitle: 'Diamond Trust Bank',
    type: 'bank',
    primaryColorHex: '#C8183F',
    secondaryColorHex: '#7A0B24',
    accentColorHex: '#FCB116',
    logoAsset: 'assets/brands/dtb.jpg',
    group: PaymentProviderGroup.bank,
    fullBleedBadge: true,
  );

  static const family = PaymentProvider(
    id: 'brand_family',
    name: 'Family Bank',
    subtitle: 'Family Bank Kenya',
    type: 'bank',
    primaryColorHex: '#364AA7',
    secondaryColorHex: '#1A255E',
    accentColorHex: '#5E9ED6',
    logoAsset: 'assets/brands/family.jpg',
    group: PaymentProviderGroup.bank,
    fullBleedBadge: true,
  );

  static const sidian = PaymentProvider(
    id: 'brand_sidian',
    name: 'Sidian Bank',
    subtitle: 'Sidian Bank Kenya',
    type: 'bank',
    primaryColorHex: '#5D1399',
    secondaryColorHex: '#36065E',
    accentColorHex: '#FF5252',
    logoAsset: 'assets/brands/sidian.jpg',
    group: PaymentProviderGroup.bank,
    fullBleedBadge: true,
  );

  static const List<PaymentProvider> banks = [
    equity,
    kcb,
    coop,
    ncba,
    absa,
    scb,
    im,
    stanbic,
    dtb,
    family,
    sidian,
  ];

  static const List<PaymentProvider> mobileMoney = [
    mpesa,
    airtel,
    tkash,
  ];

  static const List<PaymentProvider> cashWallets = [
    cash,
  ];

  static const List<PaymentProvider> all = [
    ...mobileMoney,
    ...cashWallets,
    ...banks,
  ];

  static final Map<String, PaymentProvider> _byId = {
    for (final p in all) p.id: p,
  };

  static PaymentProvider? byId(String? id) => id == null ? null : _byId[id];

  static PaymentProvider? resolve({
    String? icon,
    String? name,
    String? type,
  }) {
    final byIcon = byId(icon);
    if (byIcon != null) return byIcon;

    final lowerName = (name ?? '').toLowerCase();
    if (lowerName.contains('m-pesa') || lowerName.contains('mpesa')) {
      return mpesa;
    }
    if (lowerName.contains('airtel')) return airtel;
    if (lowerName.contains('t-kash') || lowerName.contains('tkash')) {
      return tkash;
    }
    if (lowerName.contains('equity')) return equity;
    if (lowerName.contains('kcb')) return kcb;
    if (lowerName.contains('co-op') ||
        lowerName.contains('coop') ||
        lowerName.contains('cooperative')) {
      return coop;
    }
    if (lowerName.contains('ncba') || lowerName.contains('cba')) return ncba;
    if (lowerName.contains('absa') || lowerName.contains('barclays')) {
      return absa;
    }
    if (lowerName.contains('standard chartered') ||
        lowerName.contains('stanchart') ||
        lowerName.contains('scb')) {
      return scb;
    }
    if (lowerName.contains('i&m') || lowerName.contains('i & m')) return im;
    if (lowerName.contains('stanbic')) return stanbic;
    if (lowerName.contains('dtb') || lowerName.contains('diamond trust')) {
      return dtb;
    }
    if (lowerName.contains('family')) return family;
    if (lowerName.contains('sidian')) return sidian;
    if (lowerName == 'cash' || type == 'cash') return cash;
    if (type == 'mpesa') return mpesa;
    if (type == 'airtel') return airtel;
    return null;
  }
}
