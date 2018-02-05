-- utility functions
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end
function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do
    if string.sub(line,1,1) ~= '#' then
      lines[#lines + 1] = line
    end
  end
  return lines
end
function split(str, sep)
  local fields = {}
  local sep = sep or " "
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(str, pattern, function(c) fields[#fields + 1] = c end)

  return fields
end

options.timeout = 120
options.subscribe = true

lines = lines_from('/root/accounts/imap_accounts.txt')
-- loop on all lines contents
for k,v in pairs(lines) do
  fields = split(v, '\t')
  --for idx,value in pairs(fields) do
  --  print('line[' .. k .. '] fields['..idx..']='..value)
  --end
  account = IMAP {
    server = fields[1],
    username = fields[2],
    password = fields[3],
    ssl = 'ssl23'
  }
  print('getting flagged messages from folder '..fields[2]..'/'..fields[5])
  msgs = account[fields[5]]:is_flagged()
  print('moving '..#msgs..' flagged messages to folder '..fields[2]..'/'..fields[4])
  msgs:move_messages(account[fields[4]])
  msgs = account[fields[4]]:is_flagged()
  print('unflagging '..#msgs..' flagged messages in folder '..fields[2]..'/'..fields[4])
  msgs:unmark_flagged()
end
