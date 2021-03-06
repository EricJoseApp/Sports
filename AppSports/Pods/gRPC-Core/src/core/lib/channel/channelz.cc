/*
 *
 * Copyright 2017 gRPC authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include <grpc/impl/codegen/port_platform.h>

#include "src/core/lib/channel/channelz.h"

#include <grpc/grpc.h>
#include <grpc/support/alloc.h>
#include <grpc/support/log.h>
#include <grpc/support/string_util.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "src/core/lib/channel/channelz_registry.h"
#include "src/core/lib/channel/status_util.h"
#include "src/core/lib/gpr/string.h"
#include "src/core/lib/gpr/useful.h"
#include "src/core/lib/gprpp/memory.h"
#include "src/core/lib/iomgr/error.h"
#include "src/core/lib/slice/slice_internal.h"
#include "src/core/lib/surface/channel.h"
#include "src/core/lib/transport/error_utils.h"

namespace grpc_core {
namespace channelz {

ChannelNode::ChannelNode(grpc_channel* channel, size_t channel_tracer_max_nodes)
    : channel_(channel), target_(nullptr), channel_uuid_(-1) {
  trace_.Init(channel_tracer_max_nodes);
  target_ = UniquePtr<char>(grpc_channel_get_target(channel_));
  channel_uuid_ = ChannelzRegistry::Register(this);
  gpr_atm_no_barrier_store(&last_call_started_millis_,
                           (gpr_atm)ExecCtx::Get()->Now());
}

ChannelNode::~ChannelNode() {
  trace_.Destroy();
  ChannelzRegistry::Unregister(channel_uuid_);
}

void ChannelNode::RecordCallStarted() {
  gpr_atm_no_barrier_fetch_add(&calls_started_, (gpr_atm)1);
  gpr_atm_no_barrier_store(&last_call_started_millis_,
                           (gpr_atm)ExecCtx::Get()->Now());
}

void ChannelNode::PopulateConnectivityState(grpc_json* json) {}

void ChannelNode::PopulateChildRefs(grpc_json* json) {}

char* ChannelNode::RenderJSON() {
  // We need to track these three json objects to build our object
  grpc_json* top_level_json = grpc_json_create(GRPC_JSON_OBJECT);
  grpc_json* json = top_level_json;
  grpc_json* json_iterator = nullptr;
  // create and fill the ref child
  json_iterator = grpc_json_create_child(json_iterator, json, "ref", nullptr,
                                         GRPC_JSON_OBJECT, false);
  json = json_iterator;
  json_iterator = nullptr;
  json_iterator = grpc_json_add_number_string_child(json, json_iterator,
                                                    "channelId", channel_uuid_);
  // reset json iterators to top level object
  json = top_level_json;
  json_iterator = nullptr;
  // create and fill the data child.
  grpc_json* data = grpc_json_create_child(json_iterator, json, "data", nullptr,
                                           GRPC_JSON_OBJECT, false);
  json = data;
  json_iterator = nullptr;
  PopulateConnectivityState(json);
  json_iterator = grpc_json_create_child(
      json_iterator, json, "target", target_.get(), GRPC_JSON_STRING, false);
  // fill in the channel trace if applicable
  grpc_json* trace = trace_->RenderJSON();
  if (trace != nullptr) {
    // we manuall link up and fill the child since it was created for us in
    // ChannelTrace::RenderJSON
    json_iterator = grpc_json_link_child(json, trace, json_iterator);
    trace->parent = json;
    trace->value = nullptr;
    trace->key = "trace";
    trace->owns_value = false;
  }
  // reset the parent to be the data object.
  json = data;
  json_iterator = nullptr;
  // We use -1 as sentinel values since proto default value for integers is
  // zero, and the confuses the parser into thinking the value weren't present
  json_iterator = grpc_json_add_number_string_child(
      json, json_iterator, "callsStarted", calls_started_);
  json_iterator = grpc_json_add_number_string_child(
      json, json_iterator, "callsSucceeded", calls_succeeded_);
  json_iterator = grpc_json_add_number_string_child(
      json, json_iterator, "callsFailed", calls_failed_);
  gpr_timespec ts =
      grpc_millis_to_timespec(last_call_started_millis_, GPR_CLOCK_REALTIME);
  json_iterator =
      grpc_json_create_child(json_iterator, json, "lastCallStartedTimestamp",
                             gpr_format_timespec(ts), GRPC_JSON_STRING, true);
  json = top_level_json;
  json_iterator = nullptr;
  PopulateChildRefs(json);

  // render and return the over json object
  char* json_str = grpc_json_dump_to_string(top_level_json, 0);
  grpc_json_destroy(top_level_json);
  return json_str;
}

RefCountedPtr<ChannelNode> ChannelNode::MakeChannelNode(
    grpc_channel* channel, size_t channel_tracer_max_nodes) {
  return MakeRefCounted<grpc_core::channelz::ChannelNode>(
      channel, channel_tracer_max_nodes);
}

SubchannelNode::SubchannelNode() {
  subchannel_uuid_ = ChannelzRegistry::Register(this);
}

SubchannelNode::~SubchannelNode() {
  ChannelzRegistry::Unregister(subchannel_uuid_);
}

}  // namespace channelz
}  // namespace grpc_core
