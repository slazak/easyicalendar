<template>
  <div>
    <h1>Enter Event details</h1>
    <form @submit.prevent="generateICS">
      <label for="event-name">Calendar Event Name: </label>
      <input v-model="eventName" id="event-name" required><br>
      <label for="event-date">Event Date: </label>
      <input v-model="eventDate" type="date" id="event-date" required><br>
      <label for="event-time">Start Time: </label>
      <input v-model="eventTime" type="time" id="event-time" required><br>
      <label for="event-duration">Duration (in minutes): </label>
      <input v-model.number="eventDuration" type="number" id="event-duration" required><br>
      <label for="event-location">Link to the online meeting: </label>
      <input v-model="eventLocation" id="event-location" required><br>
      <button type="submit">Generate .ics</button>
    </form>
    <a v-if="icsLink" @click="icsLink = null" :href="icsLink" :download="invitationGen"><button>Download .ics</button></a>
  </div>
</template>

<script>
export default {
  data() {
    return {
      eventName: "",
      eventDate: "",
      eventTime: "",
      eventDuration: "",
      eventLocation: "",
      invitationGen: "",
      icsLink: null
    };
  },
  methods: {
    generateICS() {
      const startTime = this.eventTime;

      const endTime = this.calculateEndTime(startTime, this.eventDuration);

      console.log(`${this.eventDate}T${startTime}`);
      
      const eventDateStartTime = new Date(`${this.eventDate}T${startTime}`);

      const eventDateEndTime = new Date(`${this.eventDate}T${endTime}`);

      // Tworzenie zawartości pliku .ics
      const icsContent = `BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//easyicalendar.com//EN
METHOD:PUBLISH
BEGIN:VEVENT
UID:${this.generateUID()}
DTSTAMP:${this.getDateTimeToStore(new Date())}
DTSTART:${this.getDateTimeToStore(eventDateStartTime)}
DTEND:${this.getDateTimeToStore(eventDateEndTime)}
LOCATION:${this.eventLocation}
SUMMARY:${this.eventName}
END:VEVENT
END:VCALENDAR`;

      // Generowanie linku do pobrania pliku .ics
      this.invitationGen = `invitation-${this.getDateTimeToStore(eventDateStartTime)}.ics`
      const blob = new Blob([icsContent], { type: "text/calendar;charset=utf-8" });
      this.icsLink = URL.createObjectURL(blob);
    },
    generateUID() {
      const uid = Date.now().toString() + Math.floor(Math.random() * 1000);
      return uid;
    },
    getDateTimeToStore(dateToStore) {
      const year = dateToStore.getUTCFullYear();
      const month = this.padNumber(dateToStore.getUTCMonth() + 1);
      const day = this.padNumber(dateToStore.getUTCDate());
      const hours = this.padNumber(dateToStore.getUTCHours());
      const minutes = this.padNumber(dateToStore.getUTCMinutes());
      const seconds = this.padNumber(dateToStore.getUTCSeconds());

      return `${year}${month}${day}T${hours}${minutes}${seconds}Z`;
    },
    // Helper function to pad single digit numbers with leading zero
    padNumber(number) {
      return number < 10 ? '0' + number : number;
    },

    // Function to calculate the end time based on start time and duration
    calculateEndTime(startTime, duration) {
      const startHours = parseInt(startTime.slice(0, 2));
      const startMinutes = parseInt(startTime.slice(3, 5));

      const totalMinutes = startHours * 60 + startMinutes + duration;
      const endHours = Math.floor(totalMinutes / 60);
      const endMinutes = totalMinutes % 60;

      return `${this.padNumber(endHours)}:${this.padNumber(endMinutes)}`;
    }
  }
}
</script>

<style scoped>
form {
  margin-bottom: 1rem;
}
label,
input {
  margin-bottom: 0.5rem;
}
</style>
