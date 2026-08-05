import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "display", "popover", "monthYear", "daysGrid", "hourSelect", "minuteSelect"]
  static values = {
    mode: { type: String, default: "date" }
  }

  connect() {
    this.today = new Date()
    this.selectedDate = this.inputTarget.value ? new Date(this.inputTarget.value) : null
    if (this.selectedDate && isNaN(this.selectedDate.getTime())) {
      this.selectedDate = null
    }

    this.viewYear = (this.selectedDate || this.today).getFullYear()
    this.viewMonth = (this.selectedDate || this.today).getMonth()

    this.renderCalendar()
    this.updateDisplay()

    this.clickOutsideHandler = (event) => {
      if (!this.element.contains(event.target)) {
        this.closePopover()
      }
    }
    document.addEventListener("click", this.clickOutsideHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutsideHandler)
  }

  togglePopover(event) {
    if (event) event.stopPropagation()
    if (this.hasPopoverTarget) {
      const isHidden = this.popoverTarget.classList.contains("hidden")
      if (isHidden) {
        this.openPopover()
      } else {
        this.closePopover()
      }
    }
  }

  openPopover() {
    if (this.hasPopoverTarget) {
      this.popoverTarget.classList.remove("hidden")
    }
  }

  closePopover() {
    if (this.hasPopoverTarget) {
      this.popoverTarget.classList.add("hidden")
    }
  }

  prevMonth(event) {
    if (event) event.preventDefault()
    this.viewMonth--
    if (this.viewMonth < 0) {
      this.viewMonth = 11
      this.viewYear--
    }
    this.renderCalendar()
  }

  nextMonth(event) {
    if (event) event.preventDefault()
    this.viewMonth++
    if (this.viewMonth > 11) {
      this.viewMonth = 0
      this.viewYear++
    }
    this.renderCalendar()
  }

  selectDay(event) {
    if (event) event.preventDefault()
    const day = parseInt(event.currentTarget.dataset.day, 10)
    if (!day) return

    const hours = this.hasHourSelectTarget ? parseInt(this.hourSelectTarget.value, 10) : (this.selectedDate ? this.selectedDate.getHours() : 12)
    const minutes = this.hasMinuteSelectTarget ? parseInt(this.minuteSelectTarget.value, 10) : (this.selectedDate ? this.selectedDate.getMinutes() : 0)

    this.selectedDate = new Date(this.viewYear, this.viewMonth, day, hours, minutes)
    this.syncValue()
    this.renderCalendar()

    if (this.modeValue === "date") {
      this.closePopover()
    }
  }

  onTimeChange() {
    if (!this.selectedDate) {
      this.selectedDate = new Date(this.viewYear, this.viewMonth, this.today.getDate())
    }
    const hours = this.hasHourSelectTarget ? parseInt(this.hourSelectTarget.value, 10) : 12
    const minutes = this.hasMinuteSelectTarget ? parseInt(this.minuteSelectTarget.value, 10) : 0

    this.selectedDate.setHours(hours)
    this.selectedDate.setMinutes(minutes)
    this.syncValue()
  }

  syncValue() {
    if (!this.selectedDate) return

    const year = this.selectedDate.getFullYear()
    const month = String(this.selectedDate.getMonth() + 1).padStart(2, '0')
    const day = String(this.selectedDate.getDate()).padStart(2, '0')
    const hours = String(this.selectedDate.getHours()).padStart(2, '0')
    const minutes = String(this.selectedDate.getMinutes()).padStart(2, '0')

    if (this.modeValue === "datetime_local") {
      this.inputTarget.value = `${year}-${month}-${day}T${hours}:${minutes}`
    } else {
      this.inputTarget.value = `${year}-${month}-${day}`
    }

    this.updateDisplay()
  }

  updateDisplay() {
    if (this.hasDisplayTarget) {
      if (this.selectedDate) {
        const options = this.modeValue === "datetime_local"
          ? { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' }
          : { year: 'numeric', month: 'short', day: 'numeric' }
        this.displayTarget.value = this.selectedDate.toLocaleString(undefined, options)
      } else {
        this.displayTarget.value = ""
      }
    }
  }

  renderCalendar() {
    if (!this.hasDaysGridTarget || !this.hasMonthYearTarget) return

    const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    this.monthYearTarget.textContent = `${monthNames[this.viewMonth]} ${this.viewYear}`

    const firstDayIndex = new Date(this.viewYear, this.viewMonth, 1).getDay()
    const daysInMonth = new Date(this.viewYear, this.viewMonth + 1, 0).getDate()

    let html = ""

    for (let i = 0; i < firstDayIndex; i++) {
      html += `<span class="w-8 h-8"></span>`
    }

    for (let day = 1; day <= daysInMonth; day++) {
      const isSelected = this.selectedDate &&
        this.selectedDate.getFullYear() === this.viewYear &&
        this.selectedDate.getMonth() === this.viewMonth &&
        this.selectedDate.getDate() === day

      const isToday = this.today.getFullYear() === this.viewYear &&
        this.today.getMonth() === this.viewMonth &&
        this.today.getDate() === day

      let btnClass = "btn btn-sm btn-ghost w-8 h-8 p-0 font-normal rounded-lg text-content hover:bg-primary/10 hover:text-primary transition-colors"
      if (isSelected) {
        btnClass = "btn btn-sm btn-primary w-8 h-8 p-0 font-bold rounded-lg shadow-xs text-primary-contrast"
      } else if (isToday) {
        btnClass = "btn btn-sm btn-outline btn-primary w-8 h-8 p-0 font-semibold rounded-lg"
      }

      html += `<button type="button" data-action="click->date-picker#selectDay" data-day="${day}" class="${btnClass}">${day}</button>`
    }

    this.daysGridTarget.innerHTML = html
  }
}
