-- CreateTable
CREATE TABLE IF NOT EXISTS "Announcement" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "isPinned" BOOLEAN NOT NULL DEFAULT false,
    "startsAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3),
    "createdByUserId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Announcement_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX IF NOT EXISTS "Announcement_isActive_isPinned_createdAt_idx"
ON "Announcement"("isActive", "isPinned", "createdAt");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "Announcement_startsAt_idx"
ON "Announcement"("startsAt");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "Announcement_expiresAt_idx"
ON "Announcement"("expiresAt");
