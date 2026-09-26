import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = { title: 'PlantOps | Alarm & Maintenance', description: 'ระบบจัดการเครื่องจักร Alarm และงานบำรุงรักษา' };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="th"><body>{children}</body></html>; }
