# Quick Start Testing Guide

## 🚀 How to Test the Barber Admin Dashboard

### Prerequisites
- Flutter app is running
- Supabase is connected
- You have access to Supabase SQL Editor

---

## Step 1: Create a Barber User

### Option A: Using Supabase SQL Editor (Recommended)

1. **Log in to Supabase Dashboard**
2. **Navigate to SQL Editor**
3. **Run this script** (replace with your actual email):

```sql
-- Find your user ID first
SELECT id, email, type FROM users WHERE email = 'your-email@example.com';

-- Update user to be a barber (use the ID from above)
UPDATE users 
SET type = 'ADMIN' 
WHERE email = 'your-email@example.com';

-- Create a barber record (replace 'USER_ID_HERE' with your user ID)
INSERT INTO barbers (id, user_id, name, specialty, rating, avatar_url)
VALUES (
  gen_random_uuid(),           -- Generate a random UUID for barber
  'USER_ID_HERE',              -- Your user ID from the users table
  'Test Barber',               -- Barber name
  'Hair Styling & Beard Trim', -- Specialty
  5.0,                         -- Rating
  NULL                         -- Avatar URL (optional)
);

-- Verify the setup
SELECT b.*, u.email, u.type 
FROM barbers b 
JOIN users u ON b.user_id = u.id 
WHERE u.email = 'your-email@example.com';
```

### Option B: Manual Steps

1. **Go to Supabase Dashboard → Authentication → Users**
2. **Find your user** and copy the User ID
3. **Go to Table Editor → users table**
4. **Edit your user row** and set `type` = `ADMIN`
5. **Go to Table Editor → barbers table**
6. **Click "Insert row"** and fill:
   - `id`: (auto-generated)
   - `user_id`: (paste your User ID)
   - `name`: Test Barber
   - `specialty`: Hair & Beard
   - `rating`: 5.0

---

## Step 2: Test Role-Based Navigation

### As Client (Before)
1. **Log out** if logged in
2. **Create a new account** OR use an existing non-barber account
3. **Verify you see**:
   - Home screen (dashboard)
   - Schedule screen (booking)
   - Bookings screen
   - Profile screen
   - 4 tabs in bottom navigation

### As Barber (After)
1. **Log out**
2. **Log in with your barber account** (the one you converted above)
3. **Verify you see**:
   - Admin Dashboard screen
   - Profile screen
   - Only 2 tabs in bottom navigation
   - Dashboard icon instead of Home icon

---

## Step 3: Test Service CRUD

### Create a Service
1. **Go to "My Services" tab** (second tab in Admin Dashboard)
2. **Tap the Floating Action Button (+)** at bottom right
3. **Fill in the form**:
   - Service Name: `Premium Haircut`
   - Price: `45.00`
   - Duration: `45`
   - Description: `Includes wash and styling`
4. **Tap "Create"**
5. **Verify**: Service appears in the list immediately

### Edit a Service
1. **Tap on the service card** you just created
2. **Edit the price** to `50.00`
3. **Tap "Update"**
4. **Verify**: Price updates immediately in the list

### Delete a Service
1. **Tap on any service card**
2. **Tap "Delete" button** (red text)
3. **Confirm deletion** in the dialog
4. **Verify**: Service disappears from the list

### Test Client View Sees Services
1. **Log out from barber account**
2. **Log in with a client account**
3. **Go to Schedule screen** (book appointment)
4. **Verify**: You can see and select the services created by the barber

---

## Step 4: Test Appointment Management

### Create Test Appointments (as Client)
1. **Log in as a client**
2. **Go to Schedule screen**
3. **Book 2-3 appointments** with your barber
   - Choose different services
   - Choose different dates/times
4. **Verify bookings** appear in Bookings screen

### Manage Appointments (as Barber)
1. **Log out and log in as barber**
2. **Go to Schedule tab** (first tab in Dashboard)
3. **Verify**: You see the appointments from clients

### Confirm an Appointment
1. **Find a PENDING appointment**
2. **Tap "Confirm" button** (green)
3. **Verify**: 
   - Status badge changes to "CONFIRMED" (green)
   - Confirm/Cancel buttons disappear
   - Success message appears

### Cancel an Appointment
1. **Find any appointment**
2. **Tap "Cancel" button** (red outline)
3. **Confirm in dialog**
4. **Verify**:
   - Status badge changes to "CANCELLED" (red)
   - Success message appears

### Test Client Side Effects
1. **Log out and log back in as client**
2. **Go to Bookings screen**
3. **Verify**: Appointment statuses match what barber set

---

## Step 5: Test Data Synchronization

### Test 1: Service Sync
1. **As Barber**: Create a service called "Beard Styling - $25"
2. **Log out, log in as Client**
3. **Go to Schedule → Select Service**
4. **Verify**: New service is available for booking

### Test 2: Appointment Sync
1. **As Client**: Book an appointment
2. **Log out, log in as Barber**
3. **Go to Schedule tab**
4. **Verify**: New appointment appears immediately

### Test 3: Real-time Updates
1. **Open app on two devices** (or web + mobile)
2. **Log in as barber on Device 1**
3. **Log in as client on Device 2**
4. **On Device 1**: Create a service
5. **On Device 2**: Navigate to Schedule
6. **Verify**: Service appears without refresh

---

## 🎯 Quick Verification Checklist

Use this checklist to verify everything works:

### Role-Based Navigation
- [ ] Client sees 4-tab navigation (Home, Schedule, Bookings, Profile)
- [ ] Barber sees 2-tab navigation (Dashboard, Profile)
- [ ] Navigation switches automatically based on user role
- [ ] No errors on role detection

### Service CRUD (Barber Only)
- [ ] Can view all existing services
- [ ] Can create new service using FAB
- [ ] Can edit existing service by tapping it
- [ ] Can delete service with confirmation
- [ ] Form validation works (empty fields rejected)
- [ ] Success/error messages appear

### Appointment Management (Barber Only)
- [ ] Can view all upcoming appointments
- [ ] Can see client name, service, date, time, price
- [ ] Can confirm PENDING appointments
- [ ] Can cancel any appointment
- [ ] Status badges show correct colors
- [ ] Actions update database correctly

### Client View
- [ ] Can see services created by barbers
- [ ] Can book appointments with services
- [ ] Cannot access admin features
- [ ] Normal booking flow works

### Data Persistence
- [ ] Services persist after app restart
- [ ] Appointments persist after app restart
- [ ] Changes by barber visible to clients
- [ ] Changes sync across devices

---

## 🐛 Troubleshooting

### "No appointments" showing for barber
**Problem**: Schedule tab is empty but clients have booked appointments

**Solution**:
1. Verify barber record exists in `barbers` table
2. Check `user_id` in `barbers` matches your auth user ID
3. Run this SQL to verify:
```sql
SELECT b.*, u.email 
FROM barbers b 
JOIN users u ON b.user_id = u.id 
WHERE u.email = 'your-email@example.com';
```

### Services not appearing for clients
**Problem**: Barber creates service but clients can't see it

**Solution**:
1. Check if service was actually created in database
2. Verify Supabase connection is active
3. Try refreshing the services list
4. Check console for errors

### Still seeing client view as barber
**Problem**: Set user type to ADMIN but still seeing client interface

**Solution**:
1. Verify `users.type` = `'ADMIN'` (uppercase) in database
2. Log out completely and log back in
3. Clear app cache if necessary
4. Restart the app

### Cannot create services
**Problem**: Create button doesn't work or shows error

**Solution**:
1. Check form validation - all required fields filled?
2. Verify Supabase permissions for services table
3. Check if user has barber record
4. Look at console for error details

---

## 📊 Test Data Examples

### Sample Services to Create

```
Service 1:
- Name: Classic Haircut
- Price: 30.00
- Duration: 30
- Description: Traditional haircut with styling

Service 2:
- Name: Beard Trim
- Price: 20.00
- Duration: 20
- Description: Professional beard trim and shaping

Service 3:
- Name: Premium Package
- Price: 60.00
- Duration: 60
- Description: Haircut + Beard + Hot Towel

Service 4:
- Name: Kids Haircut
- Price: 25.00
- Duration: 25
- Description: Haircut for children under 12
```

---

## 🎉 Success Criteria

You've successfully tested the Barber Admin Dashboard if:

1. ✅ **Role switching works**: Different UIs for client vs barber
2. ✅ **Can create services**: Barbers can add new services via FAB
3. ✅ **Can edit services**: Tapping service opens edit dialog
4. ✅ **Can delete services**: Delete works with confirmation
5. ✅ **Services sync**: Clients see services created by barbers
6. ✅ **Can manage appointments**: Confirm/cancel buttons work
7. ✅ **Statuses update**: Appointment statuses change correctly
8. ✅ **No crashes**: App doesn't crash during any operation
9. ✅ **Data persists**: Everything saves to database
10. ✅ **UI is responsive**: No lag, smooth animations

---

## 📞 Need Help?

### Check Documentation
- **User Guide**: `BARBER_ADMIN_GUIDE.md` - Detailed feature guide
- **Architecture**: `ARCHITECTURE_OVERVIEW.md` - Technical details
- **Summary**: `BARBER_ADMIN_SUMMARY.md` - Overview

### Common Issues
- Most issues are due to incorrect user role setup
- Make sure `users.type` is exactly `'ADMIN'` (uppercase)
- Ensure barber record exists with correct `user_id`
- Check Supabase connection and permissions

### Debug Mode
Enable Flutter debug mode to see detailed logs:
```bash
flutter run --debug
```

Look for errors in the console when operations fail.

---

## ⏱️ Expected Test Time

- **Basic Role Testing**: 5 minutes
- **Service CRUD**: 10 minutes  
- **Appointment Management**: 10 minutes
- **Data Sync Testing**: 10 minutes
- **Full Test Suite**: ~30-40 minutes

---

Happy Testing! 🚀


