# Ticket 017: Notifications System

## Description
Build the in-app notification system with polling-based updates. Includes the notification UI (badge, list), JSON polling endpoint consumed by TanStack Query, and the notification expiry background task that cleans up stale notifications.

## Acceptance Criteria
- [ ] `NotificationsController` (Inertia) renders notification list page
- [ ] `Api::NotificationsController` (JSON) serves unread notifications for polling
- [ ] Polling endpoint returns notifications ordered by `created_at DESC`
- [ ] Polling interval: 3-5 seconds via TanStack Query
- [ ] `useNotifications` hook manages polling, returns unread count and notification list
- [ ] Notification badge in `TopBar` shows unread count (red dot or number)
- [ ] Mark-as-read functionality (individual and bulk)
- [ ] Notification types: `new_order`, `order_accepted`, `status_update`, `delivery_complete`
- [ ] Each notification links to the relevant order
- [ ] `NotificationExpiryWorker` (Sidekiq, `maintenance` queue): marks notifications as `expired` when associated order is no longer `open` (accepted, cancelled, expired)
- [ ] Expired notifications are excluded from the unread feed
- [ ] Notification list follows DESIGN.md: no borders, card-style items, surface hierarchy

## Dependencies
- **012** — Notification records are created by the matching/dispatch workers
- **006** — UI components (TopBar for badge)

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `app/controllers/notifications_controller.rb` — Inertia page for notification list
- `app/controllers/api/notifications_controller.rb` — JSON polling endpoint
- `app/serializers/notification_serializer.rb` — notification serialization
- `app/workers/notification_expiry_worker.rb` — scheduled expiry cleanup
- `frontend/hooks/useNotifications.ts` — TanStack Query polling hook
- `frontend/components/layout/TopBar.tsx` — add notification badge
- `config/routes.rb` — notification routes (Inertia + API namespace)

## Technical Notes
- Polling endpoint should be lightweight — only return unread, non-expired notifications:
  ```ruby
  Notification.where(user: current_user, is_read: false, is_expired: false)
              .order(created_at: :desc).limit(20)
  ```
- TanStack Query polling setup:
  ```tsx
  const { data } = useQuery({
    queryKey: ['notifications'],
    queryFn: () => fetch('/api/notifications').then(r => r.json()),
    refetchInterval: 4000, // 4 seconds
  })
  ```
- `NotificationExpiryWorker` should run every 1 minute (use `sidekiq-scheduler` or `sidekiq-cron`):
  ```ruby
  Notification.where(is_expired: false)
    .joins(:delivery_order)
    .where.not(delivery_orders: { status: :open })
    .update_all(is_expired: true)
  ```
- Mark-as-read: `PATCH /api/notifications/:id/read` or bulk `PATCH /api/notifications/read_all`
