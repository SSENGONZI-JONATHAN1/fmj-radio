export interface AppLinks {
  facebook?: string;
  twitter?: string;
  instagram?: string;
  website?: string;
}

export interface AppConfig {
  id: string;
  globalStationName: string;
  defaultLogoUrl?: string;
  primaryColorHex?: string;
  secondaryColorHex?: string;
  maintenanceMode: boolean;
  minimumAppVersion: string;
  socialMediaLinks?: AppLinks;
  createdAt: Date;
  updatedAt: Date;
}
