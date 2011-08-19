/*
Copyright (C) 2011 by Mike McQuaid

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include "qocoa_mac.h"

#include "qbutton.h"

#include <QMacCocoaViewContainer>
#include <QVBoxLayout>

#import "Foundation/NSAutoreleasePool.h"
#import "AppKit/NSButton.h"

class QButtonPrivate
{
public:
    QButtonPrivate(QButton *qButton, NSButton *nsButton,
                   QButton::BezelStyle bezelStyle)
        : qButton(qButton), nsButton(nsButton)
    {
        if (bezelStyle == QButton::Disclosure
                || bezelStyle == QButton::Circular
                || bezelStyle == QButton::HelpButton
                || bezelStyle == QButton::RoundedDisclosure)
                setText(QString());

        switch(bezelStyle) {
            case QButton::Rounded:
                qButton->setMinimumWidth(40);
                qButton->setFixedHeight(24);
                qButton->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Fixed);
                break;
            case QButton::RegularSquare:
            case QButton::TexturedSquare:
                qButton->setMinimumSize(14, 23);
                qButton->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Minimum);
                break;
            case QButton::ShadowlessSquare:
                qButton->setMinimumSize(5, 25);
                qButton->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Minimum);
                break;
            case QButton::SmallSquare:
                qButton->setMinimumSize(4, 21);
                qButton->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Minimum);
                break;
            case QButton::TexturedRounded:
                qButton->setMinimumSize(10, 22);
                qButton->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Minimum);
                break;
            case QButton::RoundRect:
            case QButton::Recessed:
                qButton->setMinimumWidth(16);
                qButton->setFixedHeight(18);
                qButton->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Fixed);
                break;
            case QButton::Inline:
                qButton->setMinimumWidth(10);
                qButton->setFixedHeight(16);
                qButton->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Fixed);
                break;
            case QButton::Disclosure:
                qButton->setMinimumWidth(13);
                qButton->setFixedHeight(13);
                qButton->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Fixed);
                break;
            case QButton::Circular:
                qButton->setMinimumSize(16, 16);
                qButton->setMaximumHeight(40);
                qButton->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Minimum);
                break;
            case QButton::HelpButton:
            case QButton::RoundedDisclosure:
                qButton->setMinimumWidth(22);
                qButton->setFixedHeight(22);
                qButton->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Fixed);
                break;
        }

        [nsButton setBezelStyle:bezelStyle];
    }

    void clicked()
    {
        emit qButton->clicked();
    }

    void setText(const QString &text)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [nsButton setTitle:fromQString(text)];
        [pool drain];
    }

    QButton *qButton;
    NSButton *nsButton;
};

@interface QButtonTarget : NSObject
{
@public
    QButtonPrivate* pimpl;
}
-(void)clicked;
@end

@implementation QButtonTarget
-(void)clicked {
    pimpl->clicked();
}
@end

QButton::QButton(QWidget *parent, BezelStyle bezelStyle) : QWidget(parent)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSButton *button = [[NSButton alloc] init];
    pimpl = new QButtonPrivate(this, button, bezelStyle);

    QButtonTarget *target = [[QButtonTarget alloc] init];
    target->pimpl = pimpl;
    [button setTarget:target];
    [button setAction:@selector(clicked)];

    QVBoxLayout *layout = new QVBoxLayout(this);
    layout->setMargin(0);
    layout->addWidget(new QMacCocoaViewContainer(button, this));

    [button release];

    [pool drain];
}

void QButton::setText(const QString &text)
{
    pimpl->setText(text);
}
