#!/usr/bin/env python3

import os
import numpy
import struct
import socket
from gnuradio import gr, blocks

class source(gr.hier_block2):
  '''Eclypse Z7 Source'''

  rates = {24000:0, 48000:1, 96000:2, 192000:3, 384000:4, 768000:5, 1536000:6}

  def __init__(self, addr, port, freq, rate, corr):
    gr.hier_block2.__init__(
      self,
      name = "eclypse_z7_source",
      input_signature = gr.io_signature(0, 0, 0),
      output_signature = gr.io_signature(1, 1, gr.sizeof_gr_complex)
    )
    self.ctrl_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    self.ctrl_sock.connect((addr, port))
    self.ctrl_sock.send(struct.pack('<I', 0))
    self.data_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    self.data_sock.connect((addr, port))
    self.data_sock.send(struct.pack('<I', 1))
    fd = os.dup(self.data_sock.fileno())
    self.connect(blocks.file_descriptor_source(gr.sizeof_gr_complex, fd), self)
    self.set_freq(freq, corr)
    self.set_rate(rate)

  def set_freq(self, freq, corr):
    self.ctrl_sock.send(struct.pack('<I', 0<<28 | int((1.0 + 1e-6 * corr) * freq)))

  def set_rate(self, rate):
    if rate in source.rates:
      code = source.rates[rate]
      self.ctrl_sock.send(struct.pack('<I', 1<<28 | code))
    else:
      raise ValueError("acceptable sample rates are 24k, 48k, 96k, 192k, 384k, 768k, 1536k")

class sink(gr.hier_block2):
  '''Eclypse Z7 Sink'''

  rates = {24000:0, 48000:1, 96000:2, 192000:3, 384000:4, 768000:5, 1536000:6}

  def __init__(self, addr, port, freq, rate, corr, ptt):
    gr.hier_block2.__init__(
      self,
      name = "eclypse_z7_sink",
      input_signature = gr.io_signature(1, 1, gr.sizeof_gr_complex),
      output_signature = gr.io_signature(0, 0, 0)
    )
    self.ctrl_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    self.ctrl_sock.connect((addr, port))
    self.ctrl_sock.send(struct.pack('<I', 2))
    self.data_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    self.data_sock.connect((addr, port))
    self.data_sock.send(struct.pack('<I', 3))
    fd = os.dup(self.data_sock.fileno())
    self.null_sink = blocks.null_sink(gr.sizeof_gr_complex)
    self.file_sink = blocks.file_descriptor_sink(gr.sizeof_gr_complex, fd)
    self.set_freq(freq, corr)
    self.set_rate(rate)
    if ptt:
      self.ptt = True
      self.ctrl_sock.send(struct.pack('<I', 2<<28))
      self.connect(self, self.file_sink)
    else:
      self.ptt = False
      self.ctrl_sock.send(struct.pack('<I', 3<<28))
      self.connect(self, self.null_sink)

  def set_freq(self, freq, corr):
    self.ctrl_sock.send(struct.pack('<I', 0<<28 | int((1.0 + 1e-6 * corr) * freq)))

  def set_rate(self, rate):
    if rate in sink.rates:
      code = sink.rates[rate]
      self.ctrl_sock.send(struct.pack('<I', 1<<28 | code))
    else:
      raise ValueError("acceptable sample rates are 24k, 48k, 96k, 192k, 384k, 768k, 1536k")

  def set_ptt(self, ptt):
    if ptt and not self.ptt:
      self.ptt = True
      self.ctrl_sock.send(struct.pack('<I', 2<<28))
      self.lock()
      self.disconnect(self, self.null_sink)
      self.connect(self, self.file_sink)
      self.unlock()
    elif not ptt and self.ptt:
      self.ptt = False
      self.ctrl_sock.send(struct.pack('<I', 3<<28))
      self.lock()
      self.disconnect(self, self.file_sink)
      self.connect(self, self.null_sink)
      self.unlock()
