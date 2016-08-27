/*
 * Copyright © 2012 Scott Perry (http://numist.net)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

#import "selector_belongsToProtocol.h"

/**
 * `selector_belongsToProtocol` solves a common problem in proxy objects for delegates where selectors that are not part of the protocol may be unintentionally forwarded to the actual delegate.
 */
BOOL selector_belongsToProtocol(SEL selector, Protocol *protocol)
{
    // protocol_getMethodDescription(protocol, selector, required, instance)
    for (int optionbits = 0; optionbits < (1 << 2); optionbits++) {
        // Check required methods first, then optional
        BOOL required = optionbits & 1;
        // Check instance methods first, then class
        BOOL instance = !(optionbits & (1 << 1));
        
        struct objc_method_description hasMethod = protocol_getMethodDescription(protocol, selector, required, instance);
        if (hasMethod.name || hasMethod.types) {
            // NSLog(@"%@ selector %@ is %@ for %s", instance ? @"Instance" : @"Class", NSStringFromSelector(selector), required ? @"required" : @"optional", protocol_getName(protocol));
            return YES;
        }
    }
    
    // NSLog(@"Selector %@ is not part of protocol %s", NSStringFromSelector(selector), protocol_getName(protocol));
    return NO;
}
