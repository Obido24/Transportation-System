-- CreateEnum
CREATE TYPE "BusHireRequestStatus" AS ENUM ('PENDING', 'CONTACTED', 'APPROVED', 'DECLINED', 'COMPLETED');

-- CreateTable
CREATE TABLE "BusHireRequest" (
    "id" TEXT NOT NULL,
    "fullNameOrOrg" TEXT NOT NULL,
    "phoneNumber" TEXT NOT NULL,
    "whatsappNumber" TEXT NOT NULL,
    "email" TEXT,
    "pickupPoint" TEXT NOT NULL,
    "dropoffPoint" TEXT NOT NULL,
    "destination" TEXT NOT NULL,
    "serviceDate" TIMESTAMP(3) NOT NULL,
    "serviceTime" TEXT NOT NULL,
    "numberOfTrips" INTEGER NOT NULL,
    "numberOfBuses" INTEGER NOT NULL,
    "eventType" TEXT NOT NULL,
    "additionalNotes" TEXT,
    "status" "BusHireRequestStatus" NOT NULL DEFAULT 'PENDING',
    "adminComments" TEXT,
    "assignedBuses" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BusHireRequest_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "BusHireRequest_status_idx" ON "BusHireRequest"("status");

-- CreateIndex
CREATE INDEX "BusHireRequest_serviceDate_idx" ON "BusHireRequest"("serviceDate");

-- CreateIndex
CREATE INDEX "BusHireRequest_createdAt_idx" ON "BusHireRequest"("createdAt");
