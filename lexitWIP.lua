--FNAM: lexit.lua
--DESC: A Lua module. The module does lexical analysis; it is written as a hand-coded state machine. 
--AUTH: Timothy Albert Kline
--CRSE: CS F331 - Programming Languages
--PROF: Glenn G. Chappell
--STRT: 15 February 2021
--UPDT: 16 February 2021
--VERS: 1.0 (4.0

local lexit = {}

--lexeme category numbers and category names/strings
lexit.KEY = 1
lexit.ID = 2
lexit.NUMLIT = 3
lexit.STRLIT = 4
lexit.OP = 5
lexit.PUNCT = 6
lexit.MAL = 7

lexit.catnames = {
  "Keyword",
  "Identifier",
  "NumericLiteral",
  "StringLiteral",
  "Operator",
  "Punctuation",
  "Malformed"
}

--[[
local function isNotCharLength(c)
  if c:len() ~= 1 then
      return true
  else
      return false
  end
end
]]

local function isWhitespace(c)
  if c:len() ~= 1 then
      return false
  elseif c == " " or c == "\t" or c == "\v" or c == "\n"
    or c == "\r" or c == "\f" then
      return true
  else
      return false
  end
end

local function isPrintableASCII(c)
  if isNotCharLength(c) then
    return false
  elseif c >= " " and c <= "~" then
    return true
  else 
    return false
  end
end

local function isIllegal(c)
  if isNotCharLength then
    return false
  elseif isWhitespace(c) then
    return false
  elseif isPrintableASCII(c) then
    return false
  else
    return true
  end
end

local function isLetter(c)
  if isNotCharLength(c) then
    return false
  elseif c >= "A" and c <= "Z" then
      return true
  elseif c >= "a" and c <= "z" then
      return true
  else
      return false
  end
end

local function isDigit(c)
  if isNotCharLength(c) then
    return false
  elseif c >= "0" and c <= "9" then
    return true
  else
    return false
  end
end

--local function isAnotherCheckFunction(c)

--https://www.lua.org/pil/11.5.html
local function Set (list)
      local set = {}
      for _, l in ipairs(list) do set[l] = true end
      return set
    end
    
local keywords = Set{
  "and",
  "char",
  "cr",
  "def",
  "dq",
  "elseif",
  "else",
  "false",
  "for", 
  "if",
  "not",
  "or",
  "readnum",
  "return",
  "true",
  "write"
}

local oprChars = Set{
  "=",
  "!",
  "+",
  "-",
  "*",
  "/",
  "%",
  "<",
  ">",
  "[",
  "]"
}  

local function isOperator(c)
  if isNotCharLength(c) then
    return false
  end
  
  for i=1,oprChars.n do
    if oprChars[i] == c then
      return true
    end
  end
  --otherwise
  return false
end


function lexit.lex(program)
  
  local pos
  local state
  local cchar
  local lexstr
  local category
  local handlers
  
  --States
  local DONE = 0
  local START = 1
  local DIGIT = 2
  local LETTER = 3
  local OPERATOR = 4
  
  local function currChar(pos)
    return program:sub(pos, pos)
  end
  
  local function nextChar()
    return currChar(pos+1)
  end
  
  local function drop1()
    pos = pos+1
  end
  
  local function add1()
    lexstr = lexstr .. currChar(pos)
    drop1()
  end
  
  local function skipWhitespace()
      while true do
          -- Skip whitespace characters
          while isWhitespace(currChar(pos)) do
              drop1()
          end

          -- Done if no comment
          if currChar(pos) ~= "#" then
              break
          end

          -- Skip comment
          drop1()  -- Drop leading "#"
          while true do
              if currChar(pos) == "\n" then
                  drop1()  -- Drop trailing "\n"
                  break
              elseif currChar(pos) == "" then  -- End of input?
                 return
              end
              drop1()  -- Drop character inside comment
          end
      end
  end  

  
  local function handle_DONE()
    error("'DONE' state should not be handled\n")
  end
  
  local function handle_START()
    if isIllegal() then
      add1()
      state = DONE
      category = lexer.MAL
    elseif isLetter(cchar) or ch == "_" then
      add1()
      state = LETTER
    elseif isDigit(cchar) then
      add1()
      state = DIGIT
    elseif isOperator(cchar) then
      add1()
      state=OPERATOR
    else
      add1()
      state = DONE
      category = lexer.PUNCT
    end
  end
  
  local function handle_LETTER()
  end
  
  local function handle_DIGIT()
  end
  
  local function handle_OPERATOR()
  end
  
  handlers = {
    [DONE]=handle_DONE,
    [START]=handle_START,
    [LETTER]=handle_LETTER,
    [OPERATOR]=handle_OPERATOR
  }
  
  local function getLexeme(dummy1, dummy2)
      if pos > program:len() then
          return nil, nil
      end
      lexstr = ""
      state = START
      while state ~= DONE do
          ch = currChar(pos)
          handlers[state]()
      end

      skipWhitespace()
      return lexstr, category
  end

  
    pos = 1
    skipWhitespace()
    return getLexeme, nil, nil
end



return lexit
  