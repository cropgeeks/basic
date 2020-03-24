<template>
  <b-card no-body>
    <b-card-header header-tag="header" class="p-1">
      <b-button @click="toggle_expanded" block href="#" v-b-toggle.inputs-accordion variant="light" class="text-left"><font-awesome-icon v-if="expanded === true" icon="angle-down" class="mr-2" key="down"/><font-awesome-icon v-if="expanded === false" icon="angle-right" class="mr-2" key="right"/>{{ heading }}</b-button>
    </b-card-header>
    <b-collapse id="inputs-accordion" accordion="my-accordion">
      <b-card-body> 
        <div class="row">
          <b-card-group deck v-for="order in orders" v-bind:key="order.id" class="ml-3">
            <b-card header-text-variant="light" header-bg-variant="dark" class="text-left mb-3">
              <template v-slot:header class="m-0">
                <h6 class="mb-0">Order - {{ order.id }}</h6>
              </template>
              <b-card-text class="mb-0">Nursery: {{ order.nurseryName }}</b-card-text>
              <b-card-text class="mb-0">Farm: {{ order.farmName }}</b-card-text>
              <b-card-text class="mb-0">Quantity: {{ order.quantity }}</b-card-text>
              <b-card-text class="mb-0">State: {{ orderStates[order.state] }}</b-card-text>
              <b-card-text class="mb-0">Last updated: {{ order.lastUpdated.toLocaleString() }}</b-card-text>
            </b-card>
          </b-card-group>
        </div>
      </b-card-body>
    </b-collapse>
  </b-card>
</template>
<script>
export default {
   data() {
    return {
      expanded: false
    };
  },
  
  props: {
    orders: Array,
    orderStates: Array,
    heading: String
  },

  methods: {
     toggle_expanded: function() {
      this.expanded = !this.expanded
    }
  }
};
</script>
<style>
</style>