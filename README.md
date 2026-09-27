# PlantOps — Alarm & Maintenance Management System

PlantOps เป็นเว็บแอปสำหรับติดตามเครื่องจักร บันทึก Alarm และจัดการงานบำรุงรักษาในโรงงาน พัฒนาด้วย Next.js และ Tailwind CSS โดยใช้ Supabase สำหรับระบบบัญชีผู้ใช้และฐานข้อมูล PostgreSQL

## ลิงก์ส่งงาน

- GitHub: <https://github.com/praethip-h-cpu/plantops>
- เว็บที่ Deploy: <https://plantops-ten.vercel.app/>
- SQL สำหรับสร้างฐานข้อมูล: [`supabase/schema.sql`](supabase/schema.sql)
- รายงานการใช้ AI: [`docs/AI-usage-report.md`](docs/AI-usage-report.md)

## ความสามารถของระบบ

- เข้าสู่ระบบและสมัครสมาชิกด้วย Supabase Auth; สมาชิกใหม่เริ่มต้นเป็น `Technician`
- จัดการ Machine: เพิ่ม แก้ไข และลบข้อมูล (Admin) พร้อมสถานะ `Running`, `Stop`, `Alarm` และ `Maintenance`
- บันทึก Alarm ตามเครื่องจักร พร้อมรหัส รายละเอียด สาเหตุ วันเวลา ระดับความรุนแรง และสถานะ `Open`, `In Progress`, `Closed`
- บันทึกและแก้ไข Maintenance: ประเภทงาน ปัญหา Action Taken ช่างผู้รับผิดชอบ วันที่ และสถานะงาน
- ค้นหาด้วยข้อความ กรองตามสถานะ และกรองช่วงวันที่สำหรับ Alarm/Maintenance
- Dashboard สรุปจำนวนเครื่องจักรตามสถานะ Alarm ที่ยังเปิดอยู่ และสัดส่วนงาน Maintenance ที่เสร็จแล้ว โดยคำนวณจากข้อมูลในฐานข้อมูล
- ส่งออกรายการ Machine, Alarm หรือ Maintenance เป็น CSV
- ตรวจฟิลด์บังคับ รูปแบบ Machine ID และ ID ซ้ำก่อนบันทึก
- ใช้งานได้บนหน้าจอมือถือและเดสก์ท็อป

## สิทธิ์ผู้ใช้

| บทบาท | สิทธิ์หลัก |
|---|---|
| Admin | ดูข้อมูลทั้งหมด จัดการ Machine และดูแลข้อมูล Alarm/Maintenance |
| Technician | ดู Machine, Dashboard และ Alarm; บันทึก Alarm และสร้าง/แก้ไข Maintenance |

การจำกัดสิทธิ์ทำทั้งในส่วนติดต่อผู้ใช้และ Row Level Security (RLS) ของ Supabase สมาชิกใหม่จะได้สิทธิ์ Technician โดยค่าเริ่มต้น การกำหนดผู้ดูแลทำใน Supabase โดยเปลี่ยน `profiles.role` ของบัญชีที่เชื่อถือได้เป็น `Admin` ห้ามเปิดเผยรหัสผ่านหรือ Secret/service-role key ในโค้ดฝั่งเว็บ

## โครงสร้างฐานข้อมูล

Supabase Auth จัดการบัญชีผู้ใช้ ส่วนตาราง `public` มี 4 ตาราง:

- `profiles`: ชื่อที่แสดงและ Role เชื่อมกับ `auth.users.id`
- `machines`: Machine ID, ชื่อ, ประเภท, ตำแหน่ง และสถานะ
- `alarms`: Alarm ที่อ้างอิง Machine พร้อมเวลา สาเหตุ ความรุนแรง สถานะ และผู้บันทึก
- `maintenance_records`: งานบำรุงรักษาที่อ้างอิง Machine พร้อมประเภท ปัญหา Action Taken ผู้รับผิดชอบ วันที่ และสถานะ

ความสัมพันธ์ Machine → Alarm และ Machine → Maintenance ใช้ foreign key และลบรายการที่อ้างอิงโดยอัตโนมัติเมื่อ Admin ลบ Machine เปิด RLS ทุกตารางตามที่กำหนดใน schema

### เตรียม Supabase

1. เปิด Supabase SQL Editor แล้วรัน [`supabase/schema.sql`](supabase/schema.sql) หนึ่งครั้ง
2. หากเคยรัน schema รุ่นก่อน ให้รัน [`supabase/permissions.sql`](supabase/permissions.sql) เพื่อเพิ่ม table grants
3. สมัครบัญชีผ่านหน้าเว็บ จากนั้นกำหนดบัญชีผู้ดูแลใน SQL Editor ตัวอย่าง:

   ```sql
   update public.profiles p
   set role = 'Admin'
   from auth.users u
   where p.id = u.id
     and u.email = 'อีเมลผู้ดูแล';
   ```

4. ใน **Authentication → URL Configuration** ตั้ง Site URL เป็น `https://plantops-ten.vercel.app` และเพิ่ม `https://plantops-ten.vercel.app` กับ `http://localhost:3000/**` ใน Redirect URLs

## เริ่มใช้งานในเครื่อง

ต้องติดตั้ง Node.js 20 ขึ้นไป จากนั้น:

1. ติดตั้งแพ็กเกจด้วย `npm install`
2. คัดลอก `.env.example` เป็น `.env.local`
3. กำหนดค่า `NEXT_PUBLIC_SUPABASE_URL` และ `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` ใน `.env.local`
4. เริ่มเว็บด้วย `npm run dev` แล้วเปิด <http://localhost:3000>

`.env.local` ถูกละเว้นโดย Git ห้าม commit ไฟล์นี้หรือใส่ Supabase Secret/service-role key ในตัวแปร `NEXT_PUBLIC_*` หากไม่มีค่า Supabase แอปจะใช้ข้อมูลตัวอย่างใน browser แทนฐานข้อมูลจริง

## GitHub Actions และ Deployment

GitHub Actions workflow ที่ [`.github/workflows/ci.yml`](.github/workflows/ci.yml) ติดตั้ง dependencies แล้ว build เมื่อ push หรือเปิด pull request ไปยัง `main` Vercel เชื่อมกับ repository และ deploy จาก branch `main`

Environment Variables ใน Vercel:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`

กำหนดค่าใน Vercel Project Settings → Environment Variables แล้ว redeploy เมื่อเปลี่ยนค่า

## โฟลเดอร์สำคัญ

```text
app/                    หน้าเว็บและสไตล์
lib/supabase.ts         การเชื่อมต่อ Supabase client
supabase/schema.sql     ตาราง ความสัมพันธ์ RLS และสิทธิ์ฐานข้อมูล
supabase/permissions.sql table grants สำหรับ schema ที่เคยสร้างแล้ว
.github/workflows/      GitHub Actions สำหรับ build
docs/                   เอกสารประกอบและรายงานการใช้ AI
```

## รายการเตรียมส่ง

- [x] GitHub repository และ Vercel URL
- [x] Supabase schema และ README
- [ ] ภาพหน้าจอ Dashboard, Machine, Alarm และ Maintenance หลังเข้าสู่ระบบ
- [x] รายงานการใช้ AI: [`docs/AI-usage-report.md`](docs/AI-usage-report.md)
