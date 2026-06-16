import React from "react";
import { EmptyState } from "@hubspot/ui-extensions";
import { hubspot } from "@hubspot/ui-extensions";

hubspot.extend(({ context }) => {
  return <NewSettingsPage context={context} />;
});

const NewSettingsPage = ({ context }) => {
  return (
    <EmptyState
      title="Nothing here yet!"
      layout="vertical"
      description="Build your application settings page here!"
    />
  );
};