export enum AnnouncementPriority {
  Low = 'Low',
  Normal = 'Normal',
  High = 'High',
  Urgent = 'Urgent'
}

export interface Announcement {
  id: string;
  title: string;
  message: string;
  actionUrl?: string;
  expiryDate: Date;
  priority: AnnouncementPriority;
  createdAt: Date;
  updatedAt: Date;
}
