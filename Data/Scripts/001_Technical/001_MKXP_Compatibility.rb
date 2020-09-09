$MKXP = !!defined?(System)

def mkxp?
  return $MKXP
end

CHARACTER_OFFSETS = {
  "p" => [0, 2],
  "g" => [0, 2],
  "y" => [0, 2],
  "q" => [0, 2]
}

def pbSetWindowText(string)
  if mkxp?
    System.set_window_title(string || System.game_title)
  else
    Win32API.SetWindowText(string || "RGSS Player")
  end
end
