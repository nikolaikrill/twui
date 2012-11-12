/*
 Copyright 2011 Twitter, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this work except in compliance with the License.
 You may obtain a copy of the License in the LICENSE file, or at:
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "TUILabel.h"
#import "TUICGAdditions.h"
#import "TUITextRenderer.h"

@interface TUILabel () {
	struct {
		unsigned useExplicitTextStorage:1;
	} _labelFlags;
}

@end

@implementation TUILabel

- (id)initWithFrame:(CGRect)frame {
	if((self = [super initWithFrame:frame])) {
		_renderer = [[TUITextRenderer alloc] init];
		
		self.renderer.verticalAlignment = TUITextVerticalAlignmentMiddle;
		self.renderer.shadowBlur = 0.0f;
		self.renderer.shadowOffset = CGSizeMake(0, 1);
		
		_lineBreakMode = TUILineBreakModeClip;
		_textAlignment = TUITextAlignmentLeft;
		
		self.minimumFontSize = 4.0f;
		self.numberOfLines = 1;
		
		self.enabled = YES;
		self.clipsToBounds = YES;
		self.userInteractionEnabled = NO;
		self.textRenderers = @[self.renderer];
	}
	
	return self;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
	if(!self.enabled)
		return nil;
	
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", nil)
												  action:@selector(copyText:) keyEquivalent:@""];
	[item setKeyEquivalent:@"c"];
	[item setKeyEquivalentModifierMask:NSCommandKeyMask];
	[item setTarget:self];
	[menu addItem:item];
	
	return menu;
}

- (void)copyText:(id)sender {
	if(!self.enabled)
		return;
	
	[[NSPasteboard generalPasteboard] clearContents];
	[[NSPasteboard generalPasteboard] writeObjects:[NSArray arrayWithObjects:self.renderer.selectedString, nil]];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[self _propogateTextStorage];
	
	CGContextSetAlpha(TUIGraphicsGetCurrentContext(), self.enabled ? 1.0f : 0.7f);
	self.renderer.frame = (CGRect) {
		.size = [self.renderer sizeConstrainedToWidth:self.bounds.size.width numberOfLines:self.numberOfLines]
	};
	
	[self.renderer draw];
}

- (TUITextStorage *)textStorage {
	if(_labelFlags.useExplicitTextStorage && !self.renderer.textStorage)
		[self _propogateTextStorage];
	
	return self.renderer.textStorage;
}

- (void)setTextStorage:(TUITextStorage *)textStorage {
	_labelFlags.useExplicitTextStorage = (textStorage == nil);
	if(!textStorage)
		return;
	
	self.renderer.textStorage = textStorage;
	[self setNeedsDisplay];
}

- (TUITextStorage *)_propogatedTextStorage {
	TUITextStorage *storage = [TUITextStorage storageWithString:self.text];
	
	if(self.font)
		storage.font = self.font;
	if(self.textColor && !self.highlighted)
		storage.color = self.textColor;
	else if(self.highlightedTextColor && (self.highlighted && self.highlightedTextColor))
		storage.color = self.highlightedTextColor;
	
	[storage setAlignment:self.textAlignment lineBreakMode:self.lineBreakMode];
	
	return storage;
}

- (void)_propogateTextStorage {
	if(!self.renderer.textStorage)
		self.renderer.textStorage = [self _propogatedTextStorage];
}

- (void)setText:(NSString *)text {
	if([text isEqualToString:_text] || !_labelFlags.useExplicitTextStorage)
		return;
	
	_text = [text copy];
	
	[self _propogateTextStorage];
	[self setNeedsDisplay];
}

- (void)setFont:(NSFont *)font {
	if([font isEqual:_font] || !_labelFlags.useExplicitTextStorage)
		return;
	
	_font = font;
	
	[self _propogateTextStorage];
	[self setNeedsDisplay];
}

- (void)setTextColor:(NSColor *)textColor {
	if([textColor isEqual:_textColor] || !_labelFlags.useExplicitTextStorage)
		return;
	
	_textColor = textColor;
	
	[self _propogateTextStorage];
	[self setNeedsDisplay];
}

- (void)setAlignment:(TUITextAlignment)alignment {
	if(alignment == _textAlignment || !_labelFlags.useExplicitTextStorage)
		return;
	
	_textAlignment = alignment;
	
	[self _propogateTextStorage];
	[self setNeedsDisplay];
}

- (void)setLineBreakMode:(TUILineBreakMode)lineBreakMode {
	if (lineBreakMode == _lineBreakMode || !_labelFlags.useExplicitTextStorage)
		return;
	
	_lineBreakMode = lineBreakMode;
	
	[self _propogateTextStorage];
	[self setNeedsDisplay];
}

- (void)setShadowColor:(NSColor *)shadowColor {
	self.renderer.shadowColor = shadowColor;
	[self setNeedsDisplay];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
	self.renderer.shadowOffset = shadowOffset;
	[self setNeedsDisplay];
}

- (NSColor *)shadowColor {
	return self.renderer.shadowColor;
}

- (CGSize)shadowOffset {
	return self.renderer.shadowOffset;
}

- (void)setEnabled:(BOOL)enabled {
	if(_enabled == enabled)
		return;
	
	_enabled = enabled;
	self.renderer.shouldRefuseFirstResponder = !enabled;
}

- (void)sizeToFit {
	self.frame = (CGRect) {
		.origin = self.frame.origin,
		.size = [self.renderer sizeConstrainedToWidth:self.bounds.size.width numberOfLines:self.numberOfLines]
	};
}

@end
