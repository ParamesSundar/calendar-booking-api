const express = require("express");
const router = express.Router();
const { v4: uuidv4 } = require("uuid");
const { isValidBooking, hasConflict } = require("../utils/validateBooking");
const bookings = require("../data/bookings");

// Get all bookings
router.get("/", (req, res) => {
  res.json(bookings);
});

// Get booking by ID
router.get("/:bookingId", (req, res) => {
  const booking = bookings.find((b) => b.id === req.params.bookingId);
  if (!booking) return res.status(404).json({ error: "Booking not found" });
  res.json(booking);
});

// Create new booking
router.post("/", (req, res) => {
  const { userId, startTime, endTime } = req.body;

  if (!userId || !startTime || !endTime)
    return res.status(400).json({ error: "Missing required fields" });

  if (!isValidBooking(startTime, endTime))
    return res.status(400).json({ error: "Invalid date format or range" });

  if (hasConflict(startTime, endTime, bookings))
    return res
      .status(409)
      .json({ error: "Time conflict with existing booking" });

  const newBooking = {
    id: uuidv4(),
    userId,
    startTime,
    endTime,
  };
  bookings.push(newBooking);
  res.status(201).json(newBooking);
});

// Delete booking by ID
router.delete("/:bookingId", (req, res) => {
  const index = bookings.findIndex((b) => b.id === req.params.bookingId);
  if (index === -1) {
    return res.status(404).json({ error: "Booking not found" });
  }

  bookings.splice(index, 1);
  res.json({ message: "Booking deleted successfully" });
});

module.exports = router;
