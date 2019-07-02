%% Copyright (c) 2013-2019 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(emqx_gw_hook_SUITE).

-compile([nowarn_export_all]).
-compile(export_all).

-include_lib("emqx/include/emqx.hrl").

-include_lib("common_test/include/ct.hrl").

-include_lib("eunit/include/eunit.hrl").

-define(HOOK_LOOKUP(H), emqx_hooks:lookup(list_to_atom(H))).

all() ->
    [{group, emqx_gw_hook_actions},
     {group, emqx_gw_hook}].

groups() ->
    [{emqx_gw_hook, [sequence], [reload, change_config]},
     {emqx_gw_hook_actions, [sequence], [validate_gw_hook]}
    ].

init_per_suite(Config) ->
    ok = ekka_mnesia:start(),
    ok = emqx_rule_registry:mnesia(boot),
    emqx_ct_helpers:start_apps([emqx, emqx_rule_engine, emqx_gw_hook]),
    Config.

end_per_suite(_Config) ->
    emqx_ct_helpers:stop_apps([emqx_gw_hook, emqx_rule_engine, emqx]).

reload(_Config) ->
    {ok, Rules} = application:get_env(emqx_gw_hook, rules),
    lists:foreach(fun({HookName, _Action}) ->
                          Hooks  = ?HOOK_LOOKUP(HookName),
                          ?assertEqual(true, length(Hooks) > 0)
                  end, Rules).

change_config(_Config) ->
    {ok, Rules} = application:get_env(emqx_gw_hook, rules),
    emqx_gw_hook:unload(),
    HookRules = lists:keydelete("message.deliver", 1, Rules),
    application:set_env(emqx_gw_hook, rules, HookRules),
    emqx_gw_hook:load(),
    %?assertEqual([], ?HOOK_LOOKUP("message.deliver")),
    emqx_gw_hook:unload(),
    application:set_env(emqx_gw_hook, rules, Rules),
    emqx_gw_hook:load().

validate_gw_hook(_Config) ->
    http_server:start_http(),
    {ok, _} = emqx_client:connect(C),
    emqx_client:disconnect(C),
    ValidateData = get_http_message(),
    [validate_http_data(A) || A <- ValidateData],
    http_server:stop_http(),
    ok.

hooks_(HookName) ->
    string:join(lists:append(["on"], string:tokens(HookName, ".")), "_").

get_http_message() ->
    get_http_message([]).

get_http_message(Acc) ->
    receive
        Info -> get_http_message([Info | Acc])
    after 
        300 ->
            [maps:from_list(jsx:decode(Info)) || [{Info, _}] <- Acc]
    end.

validate_http_data(#{<<"action">> := <<"client_connected">>,<<"client_id">> := ClientId, <<"username">> := Username}) ->
    ?assertEqual(<<"simpleClient">>, ClientId),
    ?assertEqual(<<"username">>, Username);
validate_http_data(#{<<"action">> := <<"client_disconnected">>, <<"client_id">> := ClientId,
                <<"username">> := Username}) ->
    ?assertEqual(<<"simpleClient">>, ClientId),
    ?assertEqual(<<"username">>, Username);
validate_http_data(_ValidateData) ->
    ct:fail("fail").
