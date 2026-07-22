#!/usr/bin/env bash

deployment_service_execute_plan() {

    plan_validate || return 1

    plan_execute

}
