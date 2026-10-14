const element = document.currentScript.parentElement;
const settings = JSON.parse(decodeURIComponent(document.currentScript.dataset.settings));

//setting defaults from widgetstar
const cd_date = settings.enddate;
const cd_time = settings.endtime;
const hour12 = settings.hour12 ?? true;
//const timezone = settings.timezone;
const cd_title = `Countdown Until ` + settings.title;

//setting appearance customization
const bg_color = settings.bg;
const border_color = settings.border_color;
const title_color = settings.title_color;
const othertxt_color = settings.text_color;

//creating css
const css = document.createElement(`style`);

css.textContent = `
.cd_body {
    background-color: ${bg_color};
    border: 1px solid ${border_color};
    width: fit-content;
    padding: 0px 20px 0px 20px;
}

.cd_body h1, .cd_body p {
    text-align: center;
}

.cd_body .title {
    margin: 10px 0;
    height: auto;
    line-height: normal;
    letter-spacing: normal;
    white-space: normal;
    color: ${title_color};
    font-weight: bold;
    font-size: clamp(1rem, 3vw, 2em);
}

.cd_body p {
    color: ${othertxt_color};
    font-size: clamp(0.7rem, 1vw, 1em);
}
`;
//creating css

document.head.appendChild(css);

//set final countdown date
var final_date = new Date(
    (cd_time === null || cd_time === ``)
        ? `${cd_date}T00:00:00`
        : `${cd_date}T${cd_time}:00`
).getTime();

//creating countdown date string
//this part was pretty much 90% created by friends who allowed me to take all the credit. thank you guys
const cd_string = (() => {
    const date = new Date(final_date);

    const months = [`January`,`February`,`March`,`April`,`May`,`June`,`July`,`August`,`September`,`October`,`November`,`December`];

    const day = date.getDate();
    const year = date.getFullYear();
    const month = months[date.getMonth()];

    //ADDING THE FUCK ASS SUFFIX I DECIDED TO DO FOR SOME DUMBFUCK REASON
    const suffix =
        day % 10 === 1 && day !== 11 ? "st" :
        day % 10 === 2 && day !== 12 ? "nd" :
        day % 10 === 3 && day !== 13 ? "rd" : "th";

    //dont show time if equal to 00:00:00 (wont show if time isnt set cuz if time is null it is set to 00:00:00)
    if (date.getHours() === 0 && date.getMinutes() === 0 && date.getSeconds() === 0) {
        return `${month} ${day}${suffix}, ${year}`; //PART ONE DONE WITHOUT AM/PM (if selected)
    }

    let hours = date.getHours();
    const minutes = String(date.getMinutes()).padStart(2, "0");

    //now adding am/pm
    if (hour12) {
        const am_pm = hours >= 12 ? "PM" : "AM";
        hours = hours % 12 || 12;
        return `${month} ${day}${suffix}, ${year}, ${hours}:${minutes} ${am_pm}`;
    } else {
        const hours24 = String(hours).padStart(2, "0");
        return `${month} ${day}${suffix}, ${year}, ${hours24}:${minutes}`; //our FINAL string for the date (if am/pm selected).
    }
})();

//ACTUIALLY MAKING THE COUNTDOWN
var x = setInterval(function() {

    //time right now
    var now = new Date().getTime();

    //how far is result from time right now
    var distance = final_date - now;

    //calculating shit i dont really understand (thanks w3schools)
    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((distance % (1000 * 60)) / 1000);

    //change text to be all happy when countdown is done
    if (distance < 0) {
        clearInterval(x);

        element.innerHTML =
        `
        <div class="cd_body">
          <h1 class="title">${cd_title}</h1>
          <p>${cd_string}</p>
          <p>Now! :D</p>
        </div>
        `;
        return;
    }

    //MAKING THE WIDJET!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    element.innerHTML =
    `
    <div class="cd_body">
      <h1 class="title">${cd_title}</h1>
      <p>${cd_string}</p>
      <p>
        ${days} ${days === 1 ? "Day" : "Days"}, ${hours} ${hours === 1 ? "Hour" : "Hours"}, ${minutes} ${minutes === 1 ? "Minute" : "Minutes"}
      </p>
    </div>
    `;
}, 1000);

//thank you w3schools and tgc discordians this was so fucking hard for no reason ur help saved me
