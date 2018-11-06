﻿if $*.to_s.include?("/autostart")==false
eval(IO.read("bin/fiddle.dat"))
else
$LOAD_PATH << File.dirname(__FILE__)
eval(IO.read(File.dirname(__FILE__)+"/fiddle.dat"))
end
if FileTest.exists?("bin/zlib.so")
require("./bin/zlib.so")
else
require("zlib.so")
end
$r=0
$cmdline=$*.to_s
if $cmdline.include?("/autostart")
$autostart=true
$eltenstarted=false
Win32API.new("kernel32","SetCurrentDirectory",'p','i').call(File.dirname(File.dirname(__FILE__))) if FileTest.exists?("elten.exe")==false
else
$eltenstarted=true
end
$stderr.reopen(File.dirname(__FILE__)+"/../temp/agent_errout.tmp","w")
begin
Win32API.new("eltenvc","WindowsVersion",'i','i').call(0) if $r==0
rescue Exception
$r=1
retry
end
if $r==1
    $appdata = "\0" * 16384
Win32API.new("kernel32","GetEnvironmentVariable",'ppi','i').call("appdata",$appdata,$appdata.bytesize)
for i in 0..$appdata.bytesize - 1
$appdata = $appdata.sub("\0","")
end
Win32API.new("kernel32","SetDllDirectory",'p','i').call($appdata+"\\elten\\bin\\elten")
end
# Audio module
# By Darkleo

module Audio
  extend self
end

class AudioFile
  attr_reader :name
  attr_reader :sound
  def initialize filename, loopmode = FMod::LOOP_OFF
    @name = filename
    @sound = FMod::Sound.new filename
    @sound.loopMode = loopmode
    @channel = @sound.play true
    @closed = false
  end
  # TODO : use method missing...
  def play
    fail 'File closed' if @closed
    @channel.paused = false
  end
  def playing?
    fail 'File closed' if @closed
    !@channel.paused?
    #@channel start paused
  end
  def pause
    fail 'File closed' if @closed
    @channel.paused = true
  end
  def paused= bool
    fail 'File closed' if @closed
    @channel.paused = bool
  end
  def paused?
    fail 'File closed' if @closed
    @channel.paused?
  end
  def volume
    fail 'File closed' if @closed
    @channel.volume
  end
  def volume= vol
    fail 'File closed' if @closed
    @channel.volume = vol
  end
  def pan
    fail 'File closed' if @closed
    @channel.pan
  end
  def pan= pa
    fail 'File closed' if @closed
    @channel.pan = pa
  end
  def frequency
    fail 'File closed' if @closed
    @channel.frequency
  end
  def frequency= freq
    fail 'File closed' if @closed
    @channel.frequency = freq
  end
  def position unit=FMod::DEFAULT_UNIT
    fail 'File closed' if @closed
    @channel.position unit
  end
  def position=(pos, unit=FMod::DEFAULT_UNIT)
    fail 'File closed' if @closed
    @channel.position= pos, unit
  end
  def close
    fail 'File already closed' if @closed
    @channel.stop
    @sound.release
    @closed = true
  end
end




# DLL handle
# By Darkleo
# Thx to for constants and methods names

module FMod
  extend self
  DLL_PATH = 'fmodex.dll'

  # FMOD_INITFLAGS flags
  INIT_NORMAL = 0
  # FMOD_RESULT flags
  OK = 0
  ERR_CHANNEL_STOLEN = 11
  ERR_FILE_NOT_FOUND = 23
  ERR_INVALID_HANDLE = 36
  # FMOD_MODE flags
  DEFAULT = 0
  LOOP_OFF = 1
  LOOP_NORMAL = 2
  LOOP_BIDI = 4
  LOOP_BITMASK = 7
  FMOD_2D = 8
  FMOD_3D = 16
  HARDWARE = 32
  SOFTWARE = 64
  CREATESTREAM = 128
  CREATESAMPLE = 256
  OPENUSER = 512
  OPENMEMORY = 1024
  OPENRAW = 2048
  OPENONLY = 4096
  ACCURATETIME = 8192
  MPEGSEARCH = 16384
  NONBLOCKING = 32768
  UNIQUE = 65536
  # The default mode that the script uses
  DEFAULT_SOFTWARWE = LOOP_OFF | FMOD_2D | SOFTWARE
  # FMOD_CHANNELINDEX flags
  CHANNEL_FREE = -1
  CHANNEL_REUSE = -2
  # FMOD_TIMEUNIT_flags
  TIMEUNIT_MS = 1
  TIMEUNIT_PCM = 2
  # The default time unit the script uses
  DEFAULT_UNIT = TIMEUNIT_MS
  # Types supported by FMOD Ex
  FILE_TYPES = ['ogg', 'aac', 'wma', 'mp3', 'wav', 'it', 'xm', 'mod', 's3m', 'mid', 'midi']

  module System
    extend self
    pre = 'FMOD_System_'
    Create       = Win32API.new DLL_PATH, pre + 'Create',       'p',     'l'
    Init         = Win32API.new DLL_PATH, pre + 'Init',         'llll',  'l'
    Close        = Win32API.new DLL_PATH, pre + 'Close',        'l',     'l'
    Release      = Win32API.new DLL_PATH, pre + 'Release',      'l',     'l'
    CreateSound  = Win32API.new DLL_PATH, pre + 'CreateSound',  'lpllp', 'l'
    CreateStream = Win32API.new DLL_PATH, pre + 'CreateStream', 'lpllp', 'l'
    PlaySound    = Win32API.new DLL_PATH, pre + 'PlaySound',    'llllp', 'l'

    def start max_channels=32, flag=INIT_NORMAL, extraDriverData=0
      temp = '\x00'*4
      Create.call temp
      @@id = temp.unpack('i')[0]
      Init.call @@id, 32, INIT_NORMAL, 0
    end
    def dispose
      return unless @@id
      Close @@id
      Release @@id
      @@id = nil
    end
    def createSound filename, mode=DEFAULT_SOFTWARWE
      filename.gsub("http://") do
      return createStream(filename,mode)
      end
      temp = '\x00'*4
      result = CreateSound.call @@id, filename, mode, 0, temp
      fail "File not found: \"#{filename}\"" if result == ERR_FILE_NOT_FOUND
      temp.unpack('i')[0]
    end
    def createStream filename, mode=DEFAULT_SOFTWARWE
      temp = '\x00'*4
      result = CreateStream.call @@id, filename, mode, 0, temp
      fail "File not found: \"#{filename}\"" if result == ERR_FILE_NOT_FOUND
      temp.unpack('i')[0]
    end
    def playSound id, paused=false, channel=nil
      temp = channel ? [channel].pack('l') : '\x00'*4
      mode = channel ? CHANNEL_REUSE : CHANNEL_FREE
      paused = paused ? 1 : 0
      PlaySound.call @@id, mode, id, paused, temp
      Channel.new temp.unpack('i')[0]
    end
  end
  System.start

  class Sound
    pre = 'FMOD_Sound_'
    Release       = Win32API.new DLL_PATH, pre + 'Release',       'l',     'l'
    GetMode       = Win32API.new DLL_PATH, pre + 'GetMode',       'lp',    'l'
    SetMode       = Win32API.new DLL_PATH, pre + 'SetMode',       'll',    'l'
    SetLoopPoints = Win32API.new DLL_PATH, pre + 'SetLoopPoints', 'lllll', 'l'
    GetLength     = Win32API.new DLL_PATH, pre + 'GetLength',     'lpl',   'l'

    attr_reader :id
    attr_reader :channel
    def initialize filename
      @id = System.createStream filename
    end
    def release
      Release.call @id
    end
    def play paused=false
      @channel = System.playSound @id, paused
    end
    def mode
      temp = '\x00'*4
      GetMode.call @id, temp
      temp.unpack('i')[0]
    end
    def mode=
      temp = '\x00'*4
      GetMode.call @id, temp
      temp.unpack('i')[0]
    end
    def loopMode
      temp = '\x00'*4
      GetMode.call @id, temp
      temp.unpack('i')[0] & LOOP_BITMASK
    end
    def loopMode= newMode
      SetMode.call @id, (mode & ~LOOP_BITMASK | newMode)
    end
    def lenght unit=DEFAULT_UNIT
      temp = '\x00'*4
      GetLength.call @id, temp, unit
      temp.unpack('i')[0]
    end
  end

  class Channel
    pre = 'FMOD_Channel_'
    Stop         = Win32API.new DLL_PATH, pre + 'Stop',         'l',   'l'
    IsPlaying    = Win32API.new DLL_PATH, pre + 'IsPlaying',    'lp',  'l'
    GetPaused    = Win32API.new DLL_PATH, pre + 'GetPaused',    'lp',  'l'
    SetPaused    = Win32API.new DLL_PATH, pre + 'SetPaused',    'll',  'l'
    GetVolume    = Win32API.new DLL_PATH, pre + 'GetVolume',    'lp',  'l'
    SetVolume    = Win32API.new DLL_PATH, pre + 'SetVolume',    'll',  'l'
    GetPan       = Win32API.new DLL_PATH, pre + 'GetPan',       'lp',  'l'
    SetPan       = Win32API.new DLL_PATH, pre + 'SetPan',       'll',  'l'
    GetFrequency = Win32API.new DLL_PATH, pre + 'GetFrequency', 'lp',  'l'
    SetFrequency = Win32API.new DLL_PATH, pre + 'SetFrequency', 'll',  'l'
    GetPosition  = Win32API.new DLL_PATH, pre + 'GetPosition',  'lpl', 'l'
    SetPosition  = Win32API.new DLL_PATH, pre + 'SetPosition',  'lll', 'l'

    attr_reader :id
    def initialize id
      @id = id
    end
    def stop
      Stop.call @id
    end
    def playing?
      temp = '\x00'*4
      IsPlaying.call @id, temp
      temp.unpack('i')[0] != 0
    end
    def paused?
      temp = '\x00'*4
      GetPaused.call @id, temp
      temp.unpack('i')[0] != 0
    end
    def paused=bool
      SetPaused.call @id, (bool ? 1 : 0)
    end
    def volume
      temp = '\x00'*4
      GetVolume.call @id, temp
      temp.unpack('f')[0]
    end
    def volume= vol
      SetVolume.call @id, [vol].pack('f').unpack('i')[0]
    end
    def pan
      temp = '\x00'*4
      GetPan.call @id, temp
      temp.unpack('f')[0]
    end
    def pan= pa
      SetPan.call @id, [pa].pack('f').unpack('i')[0]
    end
    def frequency
      temp = '\x00'*4
      GetFrequency.call @id, temp
      temp.unpack('f')[0]
    end
    def frequency= freq
      SetFrequency.call @id, [freq].pack('f').unpack('i')[0]
    end
    def position unit=DEFAULT_UNIT
      temp = '\x00'*4
      GetPosition.call @id, temp, unit
      temp.unpack('i')[0]
    end
    def position= pos, unit=DEFAULT_UNIT
      pos = pos[0] if Array === pos # why [pos, unit] ???
      SetPosition.call @id, pos, unit
    end
  end
end
module Audio
  $bgm = nil
  $bgs = nil
  $me = []
  $se = []
  def self.bgm_play(file,volume=100,pitch=100)
    file = file.to_s
    volume = volume.to_i
    pitch = pitch.to_i
    file = searchaudiofileextension(file)
if $bgm != nil
  $bgm.close
  $bgm = nil
end
$bgm = AudioFile.new(utf8(file),2)
if volume < 100
  $bgm.volume = (volume.to_f / 100.to_f).to_f
end
if pitch != 100 and pitch >= 0 and pitch <= 200
  bs = $bgm.frequency
  freq = bs.to_f * (pitch.to_f / 100.to_f).to_f
  $bgm.frequency = freq
end
$bgm.play
return file
  end
  def self.bgm_stop
    if $bgm != nil
      $bgm.close
      $bgm = nil
      return true
    end
    return false
  end
  def self.bgm_fade(time=1000)
    Thread.new do
      t = time
                    pr = ($bgm.volume.to_f / 100.to_f).to_f
        w = (t.to_f / 100.to_f / 1000.to_f).to_f
      for i in 1..100
        if $bgm != nil
        delay(w)
        $bgm.volume -= pr
      else
        break
        end
        end
      end
    end
    def self.bgs_play(file,volume=100,pitch=100)
    file = file.to_s
    volume = volume.to_i
    pitch = pitch.to_i
    file = searchaudiofileextension(file)
if $bgs != nil
  $bgs.close
  $bgs = nil
end
$bgs = AudioFile.new(utf8(file),2)
if volume < 100
  $bgs.volume = (volume.to_f / 100.to_f).to_f
end
if pitch != 100 and pitch >= 0 and pitch <= 200
  bs = $bgs.frequency
  freq = bs.to_f * (pitch.to_f / 100.to_f).to_f
  $bgs.frequency = freq
end
$bgs.play
return file
  end
  def self.bgs_stop
    if $bgs != nil
      $bgs.close
      $bgs = nil
      return true
    end
    return false
  end
    def self.bgs_fade(time=1000)
    Thread.new do
      t = time
              pr = ($bgs.volume.to_f / 100.to_f).to_f
        w = (t.to_f / 100.to_f / 1000.to_f).to_f
      for i in 1..100
        if $bgs != nil
        delay(w)
        $bgs.volume -= pr
      else
        break
        end
        end
      end
    end
    def self.me_play(file,volume=100,pitch=100)
    file = file.to_s
    volume = volume.to_i
    pitch = pitch.to_i
    file = searchaudiofileextension(file)
$me.push(AudioFile.new(utf8(file),1))
if volume < 100
  $me[$me.size - 1].volume = (volume.to_f / 100.to_f).to_f
end
if pitch != 100 and pitch >= 0 and pitch <= 200
  bs = $me[$me.size - 1].frequency
  freq = bs.to_f * (pitch.to_f / 100.to_f).to_f
  $me[$me.size - 1].frequency = freq
end
$me[$me.size - 1].play
return file
  end
  def self.me_stop
    suc = false
    for i in 0..$me.size - 1
      $me[i].close
      $me[i] = nil
    end
    $me = []
    return suc
  end
    def self.se_play(file,volume=100,pitch=100)
      file = file.to_s
    volume = volume.to_i
    pitch = pitch.to_i
    file = searchaudiofileextension(file)
$se.push(AudioFile.new(utf8(file),1))
if volume < 100
  $se[$se.size - 1].volume = (volume.to_f / 100.to_f).to_f
end
if pitch != 100 and pitch >= 0 and pitch <= 200
  bs = $se[$se.size - 1].frequency
  freq = bs.to_f * (pitch.to_f / 100.to_f).to_f
  $se[$se.size - 1].frequency = freq
end
$se[$se.size - 1].play
return file
  end
  def self.se_stop
    suc = false
for i in 0..$se.size - 1
      $se[i].close
      $se[i] = nil
      suc = true
    end
   $se = []
   return suc
  end
  def self.searchaudiofileextension(file)
    if FileTest.exist?(file) == false
ext = ['AIFF', 'ASF', 'ASX', 'DLS', 'FLAC', 'FSB', 'IT', 'M3U', 'MID', 'MOD', 'MP2', 'MP3', 'OGG', 'PLS', 'RAW', 'S3M', 'VAG', 'WAV', 'WAX', 'WMA', 'XM', 'XMA']
suc = false
for i in 0..ext.size - 1
  if FileTest.exist?(file + "." + ext[i])
    suc = true
    found = file + "." + ext[i]
    break
    end
end
if suc == true
  return found
else
  libfile = "\0" * 1024
  Win32API.new("kernel32","GetModuleFileNameA",'ipi','i').call(0,libfile,libfile.size)
  libfile.delete!("\0")
libfile = libfile.sub(File.dirname(libfile),".")
  libfile = libfile.sub(".exe",".ini")
  libfile = libfile.sub(".EXE",".INI")
  lib = "\0" * 1024
  Win32API.new("kernel32","GetPrivateProfileString",'ppppip','i').call("Game","Library","RGSS102E.dll",lib,lib.size,libfile)
  getrtppath = Win32API.new(lib, 'RGSSGetRTPPath', 'L', 'L')
    getpathwithrtp = Win32API.new(lib, 'RGSSGetPathWithRTP', 'L', 'P')
    rtp = ""
    for i in 0..1024
    rtp = getpathwithrtp.call(getrtppath.call(i))
    if rtp != ""
      break
      end
    end
    rtp = "." if rtp == ""
  return searchaudiofileextensionrtp(file,rtp)
  end
end
else
  return file
end
  def self.searchaudiofileextensionrtp(file,rtp)
file = rtp + "\\" + file
    if FileTest.exist?(file) == false
ext = ['AIFF', 'ASF', 'ASX', 'DLS', 'FLAC', 'FSB', 'IT', 'M3U', 'MID', 'MOD', 'MP2', 'MP3', 'OGG', 'PLS', 'RAW', 'S3M', 'VAG', 'WAV', 'WAX', 'WMA', 'XM', 'XMA']
suc = false
for i in 0..ext.size - 1
  if FileTest.exist?(file + "." + ext[i])
    suc = true
    found = file + "." + ext[i]
    break
    end
end
if suc == true
  return found
else
  return utf8(file)
  end
end
else
  return file
  end
end
def play(voice,volume=0,pitch=100)
volume=readini($configdata+"\\interface.ini","Interface","MainVolume","80") if volume==0
                        volume = volume.to_i
                        if FileTest.exist?("#{$soundthemepath}/SE/#{voice}.wav") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.mp3") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.ogg") or FileTest.exist?("#{$soundthemepath}/SE/#{voice}.mid")
                          Audio.se_play("#{$soundthemepath}/SE/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.wav") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.mp3") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.ogg") or FileTest.exist?("#{$soundthemepath}/BGS/#{voice}.mid")
                          Audio.bgs_play("#{$soundthemepath}/BGS/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("Audio/SE/#{voice}.wav") or FileTest.exist?("Audio/SE/#{voice}.mp3") or FileTest.exist?("Audio/SE/#{voice}.ogg") or FileTest.exist?("Audio/SE/#{voice}.mid")
                          Audio.se_play("Audio/SE/#{voice}",volume,pitch)
                          return(true)
                        end
                                                if FileTest.exist?("Audio/BGS/#{voice}.wav") or FileTest.exist?("Audio/BGS/#{voice}.mp3") or FileTest.exist?("Audio/BGS/#{voice}.ogg") or FileTest.exist?("Audio/BGS/#{voice}.mid")
                          Audio.bgs_play("Audio/BGS/#{voice}",volume,pitch)
                          return(true)
                        end
                      end

class String
  def delline(lines=1)
    self.gsub!("\004LINE\004","\r\n")    
    str = ""
foundlines = 1
    for i in 0..self.size - 1
      str += self[i..i]
      foundlines += 1 if self[i..i] == "\n"
    end
    fl = 0
    ret = ""
    for i in 0..str.size - 1
      fl += 1 if str[i..i] == "\r" or (str[i..i] == "\n" and str[i-1..i-1] != "\r")
      if foundlines - lines > fl
        ret += str[i..i]
        end
      end
      return ret.to_s
    end
    def strbyline
str = self
  byline = []
  index = 0
  byline[index] = ""
  for i in 0..str.size - 1
    if str[i..i] != "\n" and str[i..i] != "\r"
    byline[index] += str[i..i]
  elsif str[i..i] == "\n"
    index += 1
    byline[index] = ""
    end
  end
  return byline
end
def rdelete!(i)
    b = i[0]
  x = 0
  for i in 1..self.size
    if self[self.size - i] == b
      x += 1
    else
      break
    end
       end
  for i in 1..x
    chop!
    end
  end
  def maintext
    str = ""
    for i in 0..self.size - 1
            str += self[i..i]
            break if self[i+1..i+1] == "\003"
    end
    return str
  end
  def lore
    str = ""
    s = false
    for i in 0..self.size - 1
            str += self[i..i] if s == true
            s = true if self[i..i] == "\003"
    end
    return str
  end
  def b
    o = []
    for i in 0..self.size - 1
      o.push(" "[self[i]])
    end
    return o
    end
  def urlenc
    string = (self+"")
        r = string.gsub(/([^ a-zA-Z0-9_.-]+)/) do |m|
      '%' + m.unpack('H2' * m.size).join('%').upcase
    end.tr(' ', '+')
    return r
    end
  end
def loop_update
sleep(0.001)
end
  def futf8(text)
    mw = Win32API.new("kernel32", "MultiByteToWideChar", "ilpipi", "i")
    wm = Win32API.new("kernel32", "WideCharToMultiByte", "ilpipipp", "i")
    len = mw.call(0, 0, text, -1, nil, 0)
    buf = "\0" * (len*2)
    mw.call(0, 0, text, -1, buf, buf.bytesize/2)
    len = wm.call(65001, 0, buf, -1, nil, 0, nil, nil)
    ret = "\0" * len
    wm.call(65001, 0, buf, -1, ret, ret.bytesize, nil, nil)
    for i in 0..ret.bytesize - 1
      ret[i..i] = "\0" if ret[i] == 0
    end
    ret.delete!("\0")
    return ret
  end

def utf8(text)
  text = "" if text == nil or text == false
ext = "\0" if text == nil
to_char = Win32API.new("kernel32", "MultiByteToWideChar", 'ilpipi', 'i') 
to_byte = Win32API.new("kernel32", "WideCharToMultiByte", 'ilpipipp', 'i')
utf8 = 65001
w = to_char.call(utf8, 0, text.to_s, text.bytesize, nil, 0)
b = "\0" * (w*2)
w = to_char.call(utf8, 0, text.to_s, text.bytesize, b, b.bytesize/2)
w = to_byte.call(0, 0, b, b.bytesize/2, nil, 0, nil, nil)
b2 = "\0" * w
w = to_byte.call(0, 0, b, b.bytesize/2, b2, b2.bytesize, nil, nil)
return(b2)
  end
def unicode(str)
    buf="\0"*Win32API.new("kernel32","MultiByteToWideChar",'iipipi','i').call(65001,0,str,str.bytesize,nil,0)*2
Win32API.new("kernel32","MultiByteToWideChar",'iipipi','i').call(65001,0,str,str.size,buf,buf.bytesize/2)
return buf    <<"\0"
end
  def deunicode(str)
    buf="\0"*Win32API.new("kernel32","WideCharToMultiByte",'iipipi','i').call(65001,0,str,str.bytesize,nil,0)
Win32API.new("kernel32","WideCharToMultiByte",'iipipi','i').call(65001,0,str,str.bytesize,buf,buf.bytesize/2)
buf=buf<<0
buf.delete!("\0")
return buf
end
def download(source,destination)
  $downloadcount = 0 if $downloadcount == nil
  source.sub!("?","?eltc=#{$downloadcount.to_s(36)}\&")
  $downloadcount += 1
    ef = 0
  begin
  ef = Win32API.new("urlmon","URLDownloadToFile",'pppip','i').call(nil,utf8(source),utf8(destination),0,nil)
rescue Exception
  Graphics.update
  retry
end
  Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call(utf8(source))
return ef
    end
def read(file)
        createfile = Win32API.new("kernel32","CreateFile",'piipili','l')
handler = createfile.call(utf8(file),1,1|2|4,nil,4,0,0)
readfile = Win32API.new("kernel32","ReadFile",'ipipp','I')
sz = "\0"*8
Win32API.new("kernel32","GetFileSizeEx",'ip','l').call(handler,sz)
size = sz.unpack("L")[0]
b = "\0" * (size.to_i)
bp = "\0" * (size.to_i)
handleref = readfile.call(handler,b,b.size,bp,nil)
Win32API.new("kernel32","CloseHandle",'i','i').call(handler)
handler = 0
bp.delete!("\0")
return b
end
def readini(file,group,key,default="\0")
        r = "\0" * 16384
    Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call(group,key,default,r,r.bytesize,file)
    r.delete!("\0")
    return r.to_s    
  end

def speech(text,method=0)
  text = text.to_s
    text = text.gsub("\004LINE\004") {"\r\n"}
polecenie = "sapiSayString"
polecenie = "sayString" if $voice == -1
text_d = text
$speech_lasttext = text_d
Win32API.new("screenreaderapi",polecenie+"W",'pi','i').call(unicode(text_d),method) if $password != true
return text_d
end

def speech_actived
  polecenie = "sapiIsSpeaking"
  if $voice != -1
  if Win32API.new("screenreaderapi",polecenie,'v','i').call() == 0
    return(false)
  else
    return(true)
  end
else
  i = 0
  loop do
    i += 1
   Graphics.update
   Input.update
   key_update
   break if $key[0x11] or i > $speech_lasttext.bytesize * 10
 end
 return false
  end
  end
  
  def speech_stop
    polecenie = "sapiStopSpeech"
    polecenie = "stopSpeech" if $voice == -1
    Win32API.new("screenreaderapi",polecenie,'v','i').call()
    end

def speech_actived
  polecenie = "sapiIsSpeaking"
  if $voice != -1
  if Win32API.new("screenreaderapi",polecenie,'v','i').call() == 0
    return(false)
  else
    return(true)
  end
else
  i = 0
  loop do
    i += 1
   Graphics.update
   Input.update
   key_update
   break if $key[0x11] or i > $speech_lasttext.bytesize * 10
 end
 return false
  end
  end
  
  def speech_stop
    polecenie = "sapiStopSpeech"
    polecenie = "stopSpeech" if $voice == -1
    Win32API.new("screenreaderapi",polecenie,'v','i').call()
    end

def speech_wait
  while speech_actived == true
loop_update
  end
  return
end

class Reset < Exception

end

def run(file,hide=false)
  params = 'LPLLLLLLPP'
createprocess = Win32API.new('kernel32','CreateProcess', params, 'I')
    env = 0
           env = "Windows".split(File::PATH_SEPARATOR) << nil
                  env = env.pack('p*').unpack('L').first
         startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
         startinfo = [0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0] if hide
    startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
    procinfo  = [0,0,0,0].pack('LLLL')
        pr = createprocess.call(0, utf8(file), 0, 0, 0, 0, 0, 0, startinfo, procinfo)
            procinfo[0,4].unpack('L').first # pid
            return procinfo.unpack('llll')[0]
          end

def getdirectory(type)
  dr = "\0" * 1024
  Win32API.new("shell32","SHGetFolderPath",'iiiip','i').call(0,type,0,0,dr)
  dr.delete!("\0")
  fdr=futf8(dr)
    return fdr
  end

begin
    $appdata = getdirectory(26)
$eltendata = $appdata + "\\elten"
$portable=readini("./elten.ini","Elten","Portable","0").to_i
$eltendata=".\\eltendata" if $portable>0
$configdata = $eltendata + "\\config"
$bindata = $eltendata + "\\bin"
$soundthemesdata = $eltendata + "\\soundthemes"
$language = readini($configdata + "\\language.ini","Language","Language",'en_GB')
$soundthemespath = readini($configdata + "\\soundtheme.ini","SoundTheme","Path","")
    if $soundthemespath.size > 0
    $soundthemepath = $soundthemesdata + "\\" + $soundthemespath
  else
    $soundthemepath = "Audio"
    end
cmd = $*.to_s
cmd.gsub("/wait") do
sleep(3)
end
$url = "https://elten-net.eu/srv/"
Win32API.new("urlmon","URLDownloadToFile",'ppplp','i').call(nil,$url + "redirect","redirect",0,nil)
Win32API.new("wininet","DeleteUrlCacheEntry",'p','i').call($url + "redirect")
    if FileTest.exists?("redirect")
      rdr = IO.readlines("redirect")
      File.delete("redirect") if $DEBUG != true
      if rdr.size > 0
          if rdr[0].bytesize > 0
            $url = rdr[0].delete("\r\n")
            end
        end
      end
if FileTest.exists?($configdata+"\\appid.dat")
$appid=read($configdata+"\\appid.dat")
else
  $appid = ""
  chars = ("A".."Z").to_a+("a".."z").to_a+("0".."9").to_a
  64.times do
    $appid << chars[rand(chars.length-1)]
  end
    IO.write($configdata+"\\appid.dat",$appid)
  end
loop do
if FileTest.exists?("temp/agent.tmp") == false and $omitinit != true and $eltenstarted != false
Win32API.new("user32","MessageBox",'ippi','i').call(0,"Cannot load Elten Agent Temporary File...","Fatal Error",16)
break
else
if $omitinit != true
if $eltenstarted != false
ot = $token
agenttemp = read("temp/agent.tmp").split("\r\n")
File.delete("temp/agent.tmp")
$name = agenttemp[0]#.delete("\r\n")
$token = agenttemp[1]#.delete("\r\n")
$hwnd = agenttemp[2].to_i#delete("\r\n").to_i
else
run("bin/elten_tray.bin /autostart")
autologin= "\0" * 64
Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Login","AutoLogin","0",autologin,autologin.bytesize,$configdata + "\\login.ini")
autologin=autologin.delete("\0").to_i
$name = "\0" * 64
Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Login","Name","",$name,$name.bytesize,$configdata + "\\login.ini")
$name.delete!("\0")
password_c = "\0" * 64
Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Login","Password","",password_c,password_c.bytesize,$configdata + "\\login.ini")
password_c.delete!("\0")
token = "\0" * 256
Win32API.new("kernel32","GetPrivateProfileString",'pppplp','i').call("Login","Token","",token,token.bytesize,$configdata + "\\login.ini")
token.delete!("\0")
    psw = password_c
if autologin == 1
password = ""
l = false
mn = psw[psw.size - 1..psw.size - 1]
mn = mn.to_i
mn += 1
l = false
for i in 0..psw.size - 1 - mn
  if l == true
    l = false
  else
    password += psw[i..i]
    l = true
    end
  end
class Cipher

  def initialize(shuffled)
    normal = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + [' '] + [',','.','/',';',"\'",'[',']','<','>','?',"\:","\"",'{','}','-','=','_','+','`','!','@',"\#",'$','%','^',"\&",'*','(',')','_','+',"\\",'|']
    @map = normal.zip(shuffled).inject(:encrypt => {} , :decrypt => {}) do |hash,(a,b)|
      hash[:encrypt][a] = b
      hash[:decrypt][b] = a
      hash
    end
  end

  def encrypt(str)
    str.split(//).map { |char| @map[:encrypt][char] }.join
  end

  def decrypt(str)
    str.split(//).map { |char| @map[:decrypt][char] }.join
  end

end
def decrypt(msg)
 cipher = Cipher.new ar = ["K","D","w","H","X","3","e","1","S","B","g","a","y","v","I","6","u","W","C","0","9","b","z","T","A","q","U","4","O","o","E","N","r","n","m","d","k","x","P","t","R","s","J","L","f","h","Z","j","Y","5","7","l","p","c","2","8","M","V","G","i"," ","Q","F","?",">","<","\"",":","/",".",",","'",":","[","]","{","}","-","=","_","+","\\","|","@","\#","!","`","$","^","\%","\&","*",")","(","\001","\002","\003","\004","\005","\006","\007","\008","\009","\0"]
decrypted = cipher.decrypt msg
return(decrypted)
end
      password = decrypt(password)
    password = password.gsub("a`","ą")
password = password.gsub("c`","ć")
password = password.gsub("e`","ę")
password = password.gsub("l`","ł")
password = password.gsub("n`","ń")
password = password.gsub("o`","ó")
password = password.gsub("s`","ś")
password = password.gsub("x`","ź")
password = password.gsub("z`","ż")
crp=password.crypt($name)
elsif autologin==2
crp=psw
end
$version=readini("./elten.ini","Elten","Version","0").to_f
$beta=readini("./elten.ini","Elten","Beta","0").to_i
$isbeta=readini("./elten.ini","Elten","IsBeta","0").to_i
ver = $version.to_s
  ver += " BETA" if $isbeta == 1
  ver += " RC" if $isbeta == 2
ver += " AGENT"
b=0
  b=$beta if $isbeta==1
  b=$alpha if $isbeta==2
if autologin==1 or autologin==2
download($url+"login.php?login=1\&name=#{$name}\&crp=#{crp}\&version=#{ver.to_s}\&beta=#{b.to_s}","temp/agent_login.tmp")
else
download($url+"login.php?login=1\&name=#{$name}\&token=#{token}\&version=#{ver.to_s}\&beta=#{b.to_s}","temp/agent_login.tmp")
end
break if FileTest.exists?("temp/agent_login.tmp")==false
logintemp=IO.readlines("temp/agent_login.tmp")
File.delete("temp/agent_login.tmp")
break if logintemp[0].to_i!=0
$token=logintemp[1].delete("\r\n")
$hwnd=-1
end
$mes = 0
$pst = 0
$blg = 0
$blc = 0
$flt=0
$flp=0
$frn=0
$mnt=0
$knownversion=readini("./elten.ini","Elten","Version","0").to_f
$knownbeta=readini("./elten.ini","Elten","Beta","0").to_i
$isbeta=readini("./elten.ini","Elten","IsBeta","0").to_i
$ldinit=true
if $token != ot
download($url+"logout.php?name=#{$name.urlenc}\&token=#{ot}","logouttemp")
File.delete("logouttemp") if FileTest.exists?("logouttemp")
end
end
$locales={}
if FileTest.exists?("Data/locale.dat")
$localefile=File.open("Data/locale.dat","rb")
elsif FileTest.exists?("../Data/locale.dat")
$localefile=File.open("../Data/locale.dat","rb")
end
if $localefile!=nil
$locales=Marshal.load(Zlib::inflate($localefile.read))
$localefile.close
end
def _(msg)
$language = readini($configdata + "\\language.ini","Language","Language",'en_GB')
for locale in $locales
return locale[msg]||$locales[0][msg]||msg if locale['_code'][0..1].upcase==$language[0..1].upcase
end
return msg
end
$omitinit = false
tray=false
$li=0
loop do
$voice = readini($configdata + "\\sapi.ini","Sapi","Voice","0").to_i
Win32API.new("screenreaderapi","sapiSetVoice",'i','i').call($voice)
$rate = readini($configdata + "\\sapi.ini","Sapi","Rate","50").to_i
Win32API.new("screenreaderapi","sapiSetRate",'i','i').call($rate)
$hidewindow = readini($configdata + "\\interface.ini","Interface","HideWindow","0").to_i
$refreshtime = readini($configdata + "\\advanced.ini","Advanced","RefreshTime","5").to_i
$saytimeperiod = readini($configdata + "\\interface.ini","Interface","SayTimePeriod","1").to_i
$saytimetype = readini($configdata + "\\interface.ini","Interface","SayTimeType","1").to_i
$synctime = readini($configdata + "\\advanced.ini","Advanced","SyncTime","1").to_i
if $eltenstarted == true and $hwnd != nil
if $hidewindow == 1
if tray == false
if Win32API.new("user32","GetForegroundWindow",'i','i').call(0) != $hwnd and Win32API.new("user32","GetParent",'i','i').call(Win32API.new("user32","GetForegroundWindow",'i','i').call(0)) != $hwnd and Win32API.new("user32","GetFocus",'i','i').call(0) != $hwnd
if FileTest.exists?("bin/elten_tray.bin") and FileTest.exists?("temp/agent_disabletray.tmp") == false
play("minimize")
run("bin\\elten_tray.bin")
Win32API.new("user32","ShowWindow",'ii','i').call($hwnd,0)
IO.write("temp/agent_tray.tmp","")
tray=true
end
end

else
tray = false if FileTest.exists?("temp/agent_tray.tmp") == false
end
end
end
$soundthemespath = readini($configdata + "\\soundtheme.ini","SoundTheme","Path","")
    if $soundthemespath.size > 0
    $soundthemepath = $soundthemesdata + "\\" + $soundthemespath
  else
    $soundthemepath = "Audio"
    end
if $li == 0
url = $url + "agent.php?name=#{$name.urlenc}\&token=#{$token}"
url+="&chat=1" if FileTest.exists?("temp/agent_chat.tmp")
sess=[]
if download(url,"temp/agent_st.tmp") == 0
if FileTest.exists?("temp/agent_st.tmp")
sess=IO.readlines("temp/agent_st.tmp")
$srvtime=sess[1].to_i if sess[1]!=nil
File.delete("temp/agent_st.tmp")
end
if sess[0].to_i==0 and sess.size>16 and sess[5]!=nil
$fullname = sess[5].delete("\r\n")
$gender = sess[6].to_i
s = false
if sess[8].to_i > $mes
if $gender != 0
speech(_("_Agent:info_message_male")) if $loaded == true and $ldinit==false
else
speech(_("_Agent:info_message_female")) if $loaded == true and $ldinit==false
end
s = true
end
if sess[9].to_i > $pst
speech(_("_Agent:info_followedthread")) if $loaded == true and $ldinit==false
s = true
end
if sess[10].to_i > $blg
speech(_("_Agent:info_followedblog")) if $loaded == true and $ldinit==false
s = true
end
if sess[11].to_i > $blc
speech(_("_Agent:info_blogcomment")) if $loaded == true and $ldinit==false
s = true
end
if sess[12].to_i > $flt
speech(_("_Agent:info_followedforum")) if $loaded == true and $ldinit==false
s = true
end
if sess[13].to_i > $flp
speech(_("_Agent:info_followedforumpost")) if $loaded == true and $ldinit==false
s = true
end
if sess[14].to_i > $frn
speech(_("_Agent:info_contact")) if $loaded == true and $ldinit==false
s = true
end
if sess[16].to_i > $mnt
speech(_("_Agent:info_mention")) if $loaded == true and $ldinit==false
s = true
end
play("new") if s == true
$ldinit=false if $ldinit==true
$loaded = true
$mes = sess[8].to_i
$pst = sess[9].to_i
$blg = sess[10].to_i
$blc = sess[11].to_i
$flt = sess[12].to_i
$flp = sess[13].to_i
$frn = sess[14].to_i
$mnt = sess[16].to_i
$nversion=sess[2].to_f
$nbeta=sess[3].to_f
s = false
if $nversion > $knownversion+0.00001
speech(_("_Agent:info_newversion"))
s=true
end
if $nbeta > $knownbeta and $isbeta == 1
speech(_("_Agent:info_newbeta"))
s=true
end
$knownbeta=$nbeta
$knownversion=$nversion
play("new") if s==true
if FileTest.exists?("temp/agent_chat.tmp") and sess[7]!=nil
$chatmsg=sess[7].delete("\r\n") if sess[7].delete("\r\n")!=""
if $chatmsg!=$chatlastmsg
play("chat_message")
speech($chatmsg)
$chatlastmsg=$chatmsg
end
end
end
end
end
tm=$srvtime
tm=Time.now.to_i if tm==nil or $synctime==0
tim=Time.at(tm)
m=tim.min
if $timelastsay!=tim.hour*60+tim.min
if (($saytimeperiod>0 and m==0) or ($saytimeperiod>1 and m==30) or ($saytimeperiod>=2 and (m==15 or m==45)))
play("clock") if $saytimetype==1 or $saytimetype==3
speech(sprintf("%02d:%02d",tim.hour,tim.min)) if $saytimetype==1 or $saytimetype==2
end
alarms=[]
 if FileTest.exists?($configdata+"\\alarms.dat")
fp=File.open($configdata+"\\alarms.dat","rb")
alarms=Marshal.load(fp)
fp.close
end
asc=nil
for i in 0..alarms.size-1
a=alarms[i]
if tim.hour==a[0] and tim.min==a[1]
asc=i
end
end
if asc != nil
a=alarms[asc]
if a[2]==0
alarms.delete_at(asc)
fp=File.open($configdata+"\\alarms.dat","wb")
Marshal.dump(alarms,fp)
fp.close
end
@alarmplaying=true
play("alarm")
IO.write("temp/agent_alarm.tmp",asc.to_s)
end
$timelastsay=tim.hour*60+tim.min
end
if @alarmplaying == true and FileTest.exists?("temp/agent_alarm.tmp") == false
@alarmplaying=false
Audio.bgs_stop
end
sleep(0.2)
$li+=1
$li = 0 if $li >= $refreshtime*5
IO.write("temp/agent_output.tmp",$name+"\r\n"+$token+"\r\n"+$mes.to_s+"\r\n"+$pst.to_s+"\r\n"+$blg.to_s+"\r\n"+$blc.to_s)
if FileTest.exists?("temp/agent_exit.tmp") or (Win32API.new("user32","IsWindow",'i','i').call($hwnd) == 0 and $eltenstarted == true)
puts("Exiting...")
File.delete("temp/agent_exit.tmp") if FileTest.exists?("temp/agent_exit.tmp")
$break = true
break
end
if FileTest.exists?("temp/agent.tmp")
$eltenstarted=true
break
end
end
end
if $break == true
download($url+"logout.php?name=#{$name.urlenc}\&token=#{$token}","logouttemp")
File.delete("logouttemp") if FileTest.exists?("logouttemp")
break
end
end
#rescue LoadError
#retry
#rescue RuntimeError
#retry
end