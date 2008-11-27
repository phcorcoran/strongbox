/*
    Copyright (C) 2004  Whitney Young

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#if PATATE

/* WYClickView */

#import "WYClickView.h"


@implementation WYClickView

- (void)dealloc
{
	[_target release];
	[super dealloc];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if ([theEvent clickCount] > 0) {
		[self sendAction:[self action] to:[self target]];
	}
    [super mouseDown:theEvent];
}

- (void)setTarget:(id)target
{
	if (target != _target)
	{
		[_target release];
		_target = [target retain];
	}
}
- (id)target
{
	return _target;
}
- (void)setAction:(SEL)action
{
	_action = action;
}
- (SEL)action
{
	return _action;
}

@end

#endif