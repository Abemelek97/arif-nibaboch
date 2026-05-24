import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
    if (this.getCookie("user_time_zone") !== tz) {
      this.setCookie("user_time_zone", tz, 365);
    }
  }

  setCookie(name, value, days) {
    let expires = "";
    if (days) {
      const date = new Date();
      date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
      expires = "; expires=" + date.toUTCString();
    }
    const secure = window.location.protocol === "https:" ? "; Secure" : "";
    document.cookie =
      name + "=" + (value || "") + expires + "; path=/; SameSite=Lax" + secure;
  }

  getCookie(name) {
    const nameEQ = name + "=";
    const ca = document.cookie.split(";");
    for (let i = 0; i < ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) === " ") c = c.substring(1, c.length);
      if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
  }
}
