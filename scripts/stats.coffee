"use strict"

ich.addTemplate 'downloadStats', '''
    <section class="popup box" style="opacity:0">
      <h1>{{filename}}</h1>
      <div class="content">
        <p>Link created <time datetime="{{isoDate}}">{{humanDate}}</time>.</p>
        
        <h2>Total Downloads</h2>
        <ul>
          <li>{{dailyClicks}} today</li>
          <li>{{weeklyClicks}} this week</li>
          <li>{{totalClicks}} all time</li>
        </ul>
        
        <h2>By Country</h2>
        <ol>
          {{#countries}}
          <li>{{id}} ({{count}})</li>
          {{/countries}}
        </ol>
        
        <h2>By Platform</h2>
        <ol>
          {{#platforms}}
          <li>{{id}} ({{count}})</li>
          {{/platforms}}
        </ol>
        
        <h2>By Referer</h2>
        <ul>
          {{#referrers}}
          <li>{{id}} ({{count}})</li>
          {{/referrers}}
        </ul>
        
        <p>Get the <a href="{{statsUrl}}">full statistics</a> or click anywhere to close this popup.</p>
      </div>
    </section>
'''

showStats = (stats) ->
  created = new Date(stats.created)
  
  {allTime, week, day} = stats.analytics
  popup = ich.downloadStats(
    filename: /([^\/]+)$/.exec(stats.longUrl)[1]
    isoDate: created.toISOString()
    humanDate: created.toLocaleString()
    dailyClicks: day.shortUrlClicks
    weeklyClicks: week.shortUrlClicks
    totalClicks: allTime.shortUrlClicks
    countries: allTime.countries
    platforms: allTime.platforms
    referrers: allTime.referrers
    statsUrl: "#{stats.id}+"
  ).appendTo(document.body)
  
  $('<div class="overlay"></div>').appendTo(document.body)
  
  {width, height} = popup.offset()
  popup.css(
    left: "#{(window.innerWidth - width) / 2}px"
    top: "#{(window.innerHeight - height) / 2}px"
  ).animate {opacity:1}, 'fast'

showError = (error) ->
  console?.error error.message
  # TODO show an error maybe? …nah

$(document).on 'click', '.download-stats', (event) ->
  return if event.metaKey or event.altKey or event.ctrlKey or event.shiftKey
  
  url = 'https://www.googleapis.com/urlshortener/v1/url?callback=?'
  params =
    shortUrl: @href.replace(/\+$/, '')
    projection: 'FULL'
    fields: 'analytics,created,id,longUrl'
  
  $.getJSON url, params, (data) =>
    if data.error?
      showError data.error
    else
      console.log data
      showStats data
  
  event.preventDefault()

$(document).on 'click', '.overlay', (event) ->
  $('.overlay, .popup').animate {opacity:0},
    duration: 'fast'
    complete: -> this.remove()
