function isValidBooking(startTime, endTime) {
  const start = new Date(startTime);
  const end = new Date(endTime);
  return !isNaN(start) && !isNaN(end) && start < end;
}

function hasConflict(startTime, endTime, existingBookings) {
  const newStart = new Date(startTime);
  const newEnd = new Date(endTime);
  return existingBookings.some((b) => {
    const existingStart = new Date(b.startTime);
    const existingEnd = new Date(b.endTime);
    return newStart < existingEnd && newEnd > existingStart;
  });
}

module.exports = { isValidBooking, hasConflict };
