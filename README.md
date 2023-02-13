# To Run

```
ruby ./ru_lox.rb
```

OR

```
ruby ./ru_lox.rb test_file.txt
```

# Credits
Crafted by following the text "Crafting Interpreters" by Robert Nystrom

## Design Decisions
### Negative Numbers
Contrary to what is proposed in the text, I elected to include negative numbers.

This is the guidance I followed while creating this implementation:
```
-12 # => negative 12

-12.abs # => 12

a = 12
-a.abs # => negative 12

1 < -2 # => 1 less negative 2

1 -2 # => 1 minus 2
1 --2 # => 1 minus negative 2

1 - some_text # => 1 minus some_text
```

While considering the above, I realized that we want the negative to apply based on what pre/suceeds the `-`.

Minus if:
- not followed by a number (or a variable who evaluates to a number)
- preceeded by a number
- preceeded by a string
Negative if:
- followed by a number and...
- preceeded by a comparison
- preceeded by a math operator