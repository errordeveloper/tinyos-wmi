/* Copyright (c) 2010 People Power Co.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the People Power Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * PEOPLE POWER CO. OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 *
 */
#include "ppp.h"
#include "HdlcFraming.h"

/** A complete PPP daemon: the basic PPP infrastructure with an
 * instance of Link Control Protocol already linked in.
 *
 * @author Peter A. Bigot <pab@peoplepowerco.com> */
configuration PppDaemonC {
  uses {
    interface PppProtocol[ uint16_t protocol ];
    interface UartStream;
#if PLATFORM_SURF
    interface Msp430UsciError;
#endif
    interface StdControl as UartControl;
  }
  provides {
    interface SplitControl;
    interface LcpAutomaton;
    interface Ppp;
    interface GetSetOptions<PppOptions_t> as PppOptions;
    interface GetSetOptions<HdlcFramingOptions_t> as HdlcFramingOptions;
  }
} implementation {

  components PppDaemonP;
  SplitControl = PppDaemonP;

  components PppC;
  PppProtocol = PppC;
  UartStream = PppC;
#if PLATFORM_SURF
  Msp430UsciError = PppC;
#endif
  UartControl = PppC;
  PppOptions = PppC;
  Ppp = PppC;
  HdlcFramingOptions = PppC;
  PppDaemonP.PppControl -> PppC;

  components LinkControlProtocolC;
  PppC.PppProtocol[LinkControlProtocolC.Protocol] -> LinkControlProtocolC;
  LinkControlProtocolC.Ppp -> PppC;
  LinkControlProtocolC.HdlcFramingOptions -> PppC;
  LinkControlProtocolC.PppOptions -> PppC;
  LcpAutomaton = LinkControlProtocolC;

  PppDaemonP.ProtocolReject -> LinkControlProtocolC.ProtocolReject;
  PppDaemonP.LcpAutomaton -> LinkControlProtocolC;

  PppC.PppProtocolReject -> PppDaemonP;
  LinkControlProtocolC.PppRejectedProtocol -> PppC.PppRejectedProtocol;

}